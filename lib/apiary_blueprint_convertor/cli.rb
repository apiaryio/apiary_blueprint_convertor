require 'optparse'
require 'apiary_blueprint_convertor/version'
require 'apiary_blueprint_convertor/convertor.rb'

module ApiaryBlueprintConvertor
  
  class CLI
    
    attr_reader :command

    def self.start
      cli = CLI.new
      options = cli.parse_options!(ARGV)
      cli.runCommand(ARGV, options)
    end

    def runCommand(args, options)
      command = :convert if args.first.nil? || @command.nil?
      command = @command if @command

      case command
      when :convert
        Convertor.convert(args.first)
      when :version
        puts ApiaryBlueprintConvertor::VERSION
      else
        CLI.help
      end 
    end

    def parse_options!(args)
      @command = nil
      options = {}
      options_parser = OptionParser.new do |opts|
        opts.on('-v', '--version') do
          @command = :version
        end

        opts.on( '-h', '--help') do
          @command = :help
        end
      end

      options_parser.parse!
      options

    rescue OptionParser::InvalidOption => e
      puts e
      CLI.help
      exit 1
    end

    def self.help
        puts "Usage: apiary_blueprint_convertor <legacy ast file>"
        puts "\nConvert Legacy Apiary Blueprint AST into API Blueprint AST (JSON)."
        puts "If no <legacy ast file> is specified 'apiary_blueprint_convertor' will listen on stdin."
        
        puts "\nOptions:\n\n"
        puts "\t-h, --help                      Show this help"
        puts "\t-v, --version                   Show version"
        puts "\n"
    end
  end

end
