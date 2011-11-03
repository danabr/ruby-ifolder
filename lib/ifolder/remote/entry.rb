# encoding: utf-8
require 'ifolder/remote/entry_parser'

module IFolder
  module Remote
    class Entry
      attr_reader :id, :path, :mtime
      attr_accessor :connection

      def initialize(ifolder_id, id, path, mtime)
        @ifolder_id = ifolder_id
        @id = id
        @path = path
        @mtime = mtime
      end

      def name
        path.split("/").last
      end
    end

    class DirectoryEntry < Entry
      def initialize(ifolder_id, id, path, mtime)
        super
      end

      def directory?
        true
      end

      def entries
        xml = connection.call("GetEntries", ifolderID: @ifolder_id,
                              entryID: id, index: 0, max: 100).body
        EntryParser.parse(xml).map {|e| e.connection = connection; e}
      end
    end

    class FileEntry <  Entry
      CHUNK_SIZE = 1024*1024

      def initialize(ifolder_id, id, path, mtime)
        super
      end

      def directory?
        false
      end

      def content(&block)
        handle = "#{@ifolder_id}:#{id}"
        connection.call("OpenFileRead", ifolderID: @ifolder_id, entryID: id)
        begin
          loop do
            xml = connection.call("ReadFile", file:handle, size: CHUNK_SIZE).body
            b64 = Nokogiri::XML::Document.parse(xml).
                                          xpath("/xmlns:base64Binary/text()")
            break if b64.empty?
            yield b64.to_s.unpack("m").first
          end
        ensure
          connection.call("CloseFile", file: handle)
        end
      end
    end
  end
end
