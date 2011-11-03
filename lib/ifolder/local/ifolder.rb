# encoding: utf-8
require 'date'
require 'ifolder/config'

module IFolder
  module Local
    class IFolder
      def initialize(path)
        @path = path
        @parent = File.dirname(@path)
        @config = Config.new(File.join(@path, ".ifolder"))
        @config[:entries] ||= {}
      end
      
      def init
        FileUtils.mkdir_p(path)
      end

      def exists?
        File.exists?(path) && File.directory?(path)
      end

      # Makes a clone of the given ifolder, overwriting any
      # local files with corresponding files in source.
      def clone(source)
        copy(source, true)
      end

      # Updates this ifolder with the contents of the given ifolder.
      # Does only clone new or updated data.
      def update(source)
        copy(source, false)
      end

      private
      attr_accessor :config, :path
      EPOCH = Time.new(0).to_f

      def copy(source, overwrite)
        entries = source.entries
        until entries.empty?
          entry = entries.shift
          if entry.directory?
            mkdir(entry.path)
            entries += entry.entries
          else
            entry_data = entry_metadata(entry.path)
            if overwrite || entry_data[:mtime] < entry.mtime
              puts entry.path
              copy_file(entry)
            end
            entry_data[:mtime] = entry.mtime
          end
        end
        config.save
      end

      def mkdir(path)
        FileUtils.mkdir_p(File.join(@parent, path))
      end

      def copy_file(entry)
        write_file(entry.path) do |file|
          entry.content do |chunk|
            file.write(chunk)
          end
        end
      end

      def write_file(path, &block)
        File.open(File.join(@parent, path), "wb", &block)
      end

      def entry_metadata(path)
        data = config[:entries][path]
        if data.nil?
          data = config[:entries][path] = {mtime: EPOCH}
        end
        data
      end
    end
  end
end
