# encoding: utf-8
require 'yaml'

module IFolder
  class Config
    def initialize(path)
      @path = path
      FileUtils.mkdir(File.dirname(path)) rescue nil
      @config = read_config rescue {}
    end

    def [](key)
      @config[key]
    end

    def []=(key, value)
      @config[key] = value
      write_config
    end

    private

    def read_config
      YAML::load(File.read(@path))
    end

    def write_config
      File.open(@path, "w") do |file|
        file.write YAML::dump(@config)
      end
    end
  end
end
