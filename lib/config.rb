require 'yaml'
require 'optparse'
require 'ostruct'

class ConfigParser
  def self.parse(args)

    @options = OpenStruct.new
    @options.directory = "./archive"
    @options.recorded = []

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: aoi-recorder -c CONFIG"


      opts.separator "This app records icecast auditions. It's that damn simple."
      opts.separator ""

      opts.on("-c", "--config CONFIG",
              "Load config from YAML file") do |cfg|
        yml = YAML.load_file(cfg)

        @options.recorded = yml["presenters"]
        @options.directory = yml["directory"]
      end

    end

    opts.parse!(args)
    
    if @options.recorded.empty?
      raise "No config given"

      puts ""
      puts opts
      exit
    end

    @options
  end
end
