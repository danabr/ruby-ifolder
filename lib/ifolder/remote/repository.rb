# encoding: utf-8
require 'ifolder/remote/connection'
require 'ifolder/remote/ifolder'

module IFolder
  module Remote
    class Repository
      MAX_IFOLDERS = 100 # Maximum number of ifolders to fetch

      def initialize(server, username, password)
        @connection = Connection.new(server, username, password)
      end

      def list
        response = @connection.call("GetiFolders", :index => 0, :max => MAX_IFOLDERS)
        IFolder.parse_list(response.body).map {|f| f.connection = @connection ; f}
      end

      def get(name)
        list.find {|l| l.name == name }
      end
    end
  end
end
