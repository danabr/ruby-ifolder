# encoding: utf-8
require 'ifolder/local/entry.rb'

module IFolder
  module Local
    class Repository
      def initialize(home)
        @home = home
      end

      # Returns true if an ifolder of the given exists.
      def exists?(ifolder)
        path = File.join(@home, ifolder.name)
        File.exists?(path) && File.directory?(path)
      end

      # Makes a clone of the given ifolder,
      # overwriting any local files with the contents
      # of the given repository.
      def clone(ifolder, progress_tracker)
        mkdir(ifolder.name)
        download_ifolder(ifolder, progress_tracker)
      end

      private
      def mkdir(path)
        FileUtils.mkdir_p(File.join(@home, path))
      end

      def download_ifolder(ifolder, progress_tracker)
        entries = ifolder.entries
        until entries.empty?
          entry = entries.shift
          progress_tracker.puts entry.path
          if entry.directory?
            mkdir(entry.path)
            entries += entry.entries
          else
            download_file(entry)
          end
        end
      end

      def download_file(entry)
        write_file(entry.path) do |file|
          entry.content do |chunk|
            file.write(chunk)
          end
        end
      end

      def write_file(path, &block)
        File.open(File.join(@home, path), "wb", &block)
      end
    end
  end
end
