# encoding: utf-8
require 'nokogiri'
require 'date'
require 'ifolder/remote/entry'

module IFolder
  module Remote
    class EntryParser
      def self.parse(entries_xml)
        document = Nokogiri::XML::Document.parse(entries_xml)
        document.encoding = "utf-8"
        document.xpath("//xmlns:iFolderEntry").map do |entry_xml|
          parse_entry(entry_xml)
        end
      end

      private
      def self.parse_entry(entry_xml)
        id = entry_xml.xpath("xmlns:ID/text()").to_s
        name = entry_xml.xpath("xmlns:Name/text()").to_s
        path = entry_xml.xpath("xmlns:Path/text()").to_s
        ifolder_id = entry_xml.xpath("xmlns:iFolderID/text()").to_s
        is_directory = entry_xml.xpath("xmlns:IsDirectory/text()").to_s == "true"
        last_modified = entry_xml.xpath("xmlns:LastModified/text()").to_s
        last_modified = DateTime.parse(last_modified).to_time.to_f
        if is_directory
          DirectoryEntry.new(ifolder_id, id, path, last_modified)
        else
          FileEntry.new(ifolder_id, id, path, last_modified)
        end
      end
    end
  end
end
