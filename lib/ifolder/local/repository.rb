# encoding: utf-8
require 'ifolder/local/entry.rb'

module IFolder
  module Local
    class Repository
      def initialize(home)
        @home = home
      end

      def exists?(ifolder)
        path = File.join(@home, ifolder.name)
        File.exists?(path) && File.directory?(path)
      end


      def mkdir(path)
        FileUtils.mkdir_p(File.join(@home, path))
      end

      def write_file(path, &block)
        File.open(File.join(@home, path), "wb", &block)
      end
    end
  end
end
