# encoding: utf-8
require 'net/http/persistent'
require 'uri'

module IFolder
  class Connection
    WEB_SERVICE_PATH = "/simias10/iFolderWeb.asmx/".freeze

    def initialize(domain_or_ip, username, password)
      @uri = URI "https://#{domain_or_ip}"
      @auth = "Basic " + ["#{username}:#{password}"].pack('m')
      @http = Net::HTTP::Persistent.new @uri
      @cookies = "" # ifolder uses session state!
    end

    def call(path, params)
      full_path = WEB_SERVICE_PATH + path
      full_uri = @uri + full_path
      request = Net::HTTP::Post.new(full_path, {"Authorization" => @auth,
                                                "Cookie" => @cookies})
      request.set_form_data(params)
      response = @http.request(full_uri, request)
      @cookies = response["Set-Cookie"] unless response["Set-Cookie"].nil?
      raise response.body.inspect unless response.code == "200"
      response
    end

    def close
      @http.close
    end
  end
end
