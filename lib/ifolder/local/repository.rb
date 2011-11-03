# encoding: utf-8
require 'ifolder/local/ifolder'

module IFolder
  module Local
    class Repository
      def initialize(home)
        @home = home
      end

      # Returns true if an ifolder of the given name exists.
      def exists?(name)
        get(name).exists?
      end

      # Returns an ifolder with the given name
      def get(name)
        path = File.join(@home, name)
        IFolder.new(path)
      end

      # Makes a clone of the given ifolder, overwriting any local
      # files with the contents # of the given repository.
      def clone(source)
        local = get(source.name)
        local.init unless local.exists?
        local.clone(source)
      end

      # Updates the files outdated in the ifolder with the given name
      def update(source)
        ifolder = get(source.name)
        raise "No such ifolder: #{source.name}" unless ifolder.exists?
        ifolder.update(source) 
      end
    end
  end
end
