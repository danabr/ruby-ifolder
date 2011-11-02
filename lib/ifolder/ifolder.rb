# encoding: utf-8

require 'nokogiri'
require 'ifolder/entry_parser'

module IFolder
  class IFolder
    attr_reader :id, :name, :description
    attr_accessor :connection
    def initialize(id, name, description)
      @id = id
      @name = name
      @description = description
    end

    def entries
      xml = connection.call("GetEntries", :ifolderID => id, :entryID => id,
                            :index => 0, :max => 1024).body
      top_dir = EntryParser.parse(xml).first
      top_dir.connection = connection
      top_dir.entries
    end

    def self.parse_list(xml)
      ifolders = []
      document = Nokogiri::XML::Document.parse(xml)
      document.encoding = "utf-8"
      document.xpath("//xmlns:iFolder").each do |ifolder_xml|
        id = ifolder_xml.xpath("xmlns:ID/text()").to_s
        name = ifolder_xml.xpath("xmlns:Name/text()").to_s
        description = ifolder_xml.xpath("xmlns:Description/text()").to_s
        ifolders << new(id, name, description)
      end
      ifolders
    end
    
  end
end
