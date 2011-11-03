# encoding: utf-8
require 'yaml'

module IFolder
  class Config
    def initialize(path)
      @path = path
      @config = read_config rescue {}
    end

    def [](key)
      @config[key]
    end

    def []=(key, value)
      @config[key] = value
    end
    
    def save
      File.open(@path, "w") do |file|
        file.write YAML::dump(@config)
      end
    end

    private

    def read_config
      YAML::load(File.read(@path))
    end
  end
end
