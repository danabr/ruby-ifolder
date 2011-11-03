# encoding: utf-8
require 'ifolder/connection'
require 'ifolder/ifolder'

module IFolder
  class RemoteRepository
    MAX_IFOLDERS = 100

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
