require 'json'
require 'object'

module ApiaryBlueprintConvertor
  
  class Convertor

    API_BLUEPRONT_AST_VERSION = "1.0"

    def self.read_file(file)
      unless File.readable?(file)
        abort "Unable to read input ast file: #{file.inspect}"
      end      
      input = File.read(file)
    end

    # Read file / input and convert the AST
    def self.convert(file = nil)
      # Read input
      input = nil
      if file.nil?
        input = $stdin.read
      else 
        input = self.read_file(file)
      end

      if input.blank?
        puts "Empty input, bailing out!"
        exit
      end

      legacy_ast = JSON.parse(input).deep_symbolize_keys
      
      # Top level API Blueprint Template
      blueprint_ast = {
        :_version => API_BLUEPRONT_AST_VERSION,
        :metadata => nil,
        :name => nil,
        :description => nil,
        :resourceGroups => nil
      }

      # Run the conversion
      convert_blueprint(legacy_ast, blueprint_ast)
      
      # Print output to stdou
      puts JSON.pretty_generate(blueprint_ast)

    rescue JSON::ParserError => e
      abort("unable to parse input JSON: #{e}")
    end

    # Convert AST root
    def self.convert_blueprint(legacy_ast, blueprint_ast)

      # Location key
      convert_location(legacy_ast[:location], blueprint_ast) if legacy_ast[:location] 

      # Name key
      blueprint_ast[:name] = legacy_ast[:name]

      # Description
      blueprint_ast[:description] = legacy_ast[:description]

      # Sections
      convert_sections(legacy_ast[:sections], legacy_ast[:validations], blueprint_ast)

      # NOTE: Validations are processed in `convert_sections`.
    end

    # Convert Location / Metadata key
    # \param location ... location to convert
    # \param blueprint_ast ... output AST
    def self.convert_location(legacy_location, blueprint_ast)
      if legacy_location.blank?
        blueprint_ast[:metadata] = nil        
        return
      end

      blueprint_ast[:metadata] = {
        :HOST => {
          :value => "#{legacy_location}"
        }
      }
    end

    # Convert array of blueprint sections
    # \param legacy_sections ... sections to convert
    # \param legacy_validations ... legacy validations
    # \param blueprint_ast ... output AST
    def self.convert_sections(legacy_sections, legacy_validations, blueprint_ast)
      resourceGroups = [];
      legacy_sections.each do |legact_section|
        group = {
          :name => legact_section[:name],
          :description => legact_section[:description],
          :resources => nil
        }

        convert_resources(legact_section[:resources], legacy_validations, group)
        resourceGroups << group
      end

      blueprint_ast[:resourceGroups] = resourceGroups unless resourceGroups.blank?
    end

    # Convert all resources of a resource group
    # \param legacy_resources ... resources to convert
    # \param legacy_validations ... legacy validations
    # \param resource_group ... output resource group    
    def self.convert_resources(legacy_resources, legacy_validations, resource_group)
      resources = [];
      legacy_resources.each do |legacy_resource|

        resource = find_resource(resources, legacy_resource[:url])

        if (resource)
          # Existing Resource
          add_resource_action(legacy_resource, legacy_validations, resource)
        else 
          # New Resource
          resource = {
            :name => nil,
            :description => nil,
            :uriTemplate => legacy_resource[:url],
            :model => nil,
            :parameters => nil,
            :headers => nil,
            :actions => nil
          }
          
          add_resource_action(legacy_resource, legacy_validations, resource)
          resources << resource
        end
      end

      resource_group[:resources] = resources unless resources.blank?
    end

    # Look for a resource by URL in array of resources
    # \returns the matching resource or nil
    def self.find_resource(resources, uri_template)
      return nil if resources.blank?
      matches = resources.select { |resource| resource[:uriTemplate] == uri_template }
      return matches.blank? ? nil : matches.first
    end

    # Add an action entry in resources
    # \param legacy_resource ... resource with action to be converted
    # \param legacy_validations ... legacy validations    
    # \param resource ... output resource to recieve the action
    def self.add_resource_action(legacy_resource, legacy_validations, resource)

      action = find_action(resource[:actions], legacy_resource[:method])
      if action
        $stderr.write "Ignoring duplicate action definiton for resource '#{resource[:uriTemplate]}' and request method '#{action[:method]}'\n"
        return
      end

      action = {
        :name => nil,
        :description => legacy_resource[:description],
        :method => legacy_resource[:method],
        :parameters => nil,
        :headers => nil,
        :examples => nil
      }

      add_action_example(legacy_resource, legacy_validations, action)

      resource[:actions] = Array.new if resource[:actions].nil?
      resource[:actions] << action
    end

    # Look for an action by Method in array of actions
    # \returns the matching action or nil
    def self.find_action(actions, method)
      return nil if actions.blank?
      matches = actions.select { |action| action[:method] == method }
      return matches.blank? ? nil : matches.first
    end

    # Add an example entry in action
    # \param legacy_resource ... resource with example to be converted
    # \param legacy_validations ... legacy validations    
    # \param action ... output action to recieve the example
    def self.add_action_example(legacy_resource, legacy_validations, action)
      example = {
        :name => nil,
        :description => nil,
        :requests => nil,
        :responses => nil
      }

      schema = resource_schema(legacy_resource, legacy_validations)

      # Convert Request
      if legacy_resource[:request] && 
          !(legacy_resource[:request][:headers].blank? && legacy_resource[:request][:body].blank?)

        request = {
          :name => nil,
          :description => nil,
          :headers => create_headers_hash(legacy_resource[:request][:headers]),
          :body => legacy_resource[:request][:body],
          :schema => (schema) ? schema[:request] : nil
        }
        example[:requests] = Array.new
        example[:requests] << request
      end

      # Convert resources
      unless legacy_resource[:responses].blank?
        example[:responses] = Array.new
        
        legacy_resource[:responses].each do |legacy_response|
          response = {
            :name => "#{legacy_response[:status]}",
            :description => nil,
            :headers => create_headers_hash(legacy_response[:headers]),
            :body => legacy_response[:body],
            :schema => (schema) ? schema[:response] : nil
          }

          example[:responses] << response
        end
      end

      action[:examples] = Array.new if action[:examples].nil?
      action[:examples] << example
    end

    # Create an API Blueprint header hash
    # from legacy headers hash
    def self.create_headers_hash(legacy_headers)
      return nil if legacy_headers.blank?
      headers = {}

      legacy_headers.each do |key, value|
        headers[key] = {
          :value => value
        }
      end

      headers
    end

    # Returns legacy resource validation if exists, nil otherwise
    def self.legacy_resource_validation(legacy_resource, legacy_validations)
      return nil if legacy_validations.blank?

      matches = legacy_validations.select do |legacy_validation|
        (legacy_validation[:url] == legacy_resource[:url] && 
            legacy_validation[:method] == legacy_resource[:method])
      end

      return nil if matches.blank? || matches.first[:body].blank?

      matches.first[:body]
    end

    # Attempt to retrieve request and response schema from legacy validations
    # for given legacy resource
    def self.resource_schema(legacy_resource, legacy_validations)

      validation = legacy_resource_validation(legacy_resource, legacy_validations)
      return nil if validation.blank?

      # Attempt to parse validation
      validation_hash = JSON.parse(validation)
      validation_hash = validation_hash.deep_symbolize_keys

      schema = {
        :request => nil,
        :response => nil
      }

      if validation_hash.nil?
        schema[:request] = validation
        return schema
      end

      if validation_hash[:request]
        if validation_hash[:request].is_a?(Hash)
          schema[:request] = validation_hash[:request].to_json          
        else
          schema[:request] = validation_hash[:request]
        end
      end

      if validation_hash[:response]
        if validation_hash[:response].is_a?(Hash)
          schema[:response] = validation_hash[:response].to_json
        else
          schema[:response] = validation_hash[:response]
        end
      end

      if validation_hash[:request].nil? && validation_hash[:response].nil?
        schema[:request] = validation
      end
      return schema 
    rescue
      return { 
        :request => validation,
        :response => nil
      }
    end
  end
end









