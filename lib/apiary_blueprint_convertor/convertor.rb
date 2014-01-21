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
        :version => API_BLUEPRONT_AST_VERSION,
        :metadata => nil,
        :name => nil,
        :description => nil,
        :resourceGroups => nil
      }

      # Run the conversion
      convert_root(legacy_ast, blueprint_ast)
      
      # Print output to stdou
      puts JSON.pretty_generate(blueprint_ast)

    rescue JSON::ParserError => e
      abort("unable to parse input JSON: #{e}")
    end

    # Convert AST root
    def self.convert_root(legacy_ast, blueprint_ast)

      # Location key
      convert_location(legacy_ast[:location], blueprint_ast) if legacy_ast[:location] 

      # Name key
      blueprint_ast[:name] = legacy_ast[:name] unless legacy_ast[:name].blank?

      # Description
      blueprint_ast[:description] = legacy_ast[:description] unless legacy_ast[:description].blank?

      # Sections
      convert_sections(legacy_ast[:sections], blueprint_ast) unless legacy_ast[:sections].blank?

      # Validations
      # TODO:
    end

    # Convert Location / Metadata key
    def self.convert_location(location, blueprint_ast)
      return if location.blank?
      blueprint_ast[:metadata] = {
        :HOST => {
          :value => "#{location}"
        }
      }
    end

    # Convert array of blueprint sections
    def self.convert_sections(sections, blueprint_ast)
      return
    end


  end
end
