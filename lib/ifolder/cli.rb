# encoding: utf-8
require 'thor'
require 'ifolder/config'
require 'ifolder/remote_repository'
require 'ifolder/local_repository'

module IFolder
  class CLI < Thor
    def initialize(*args)
      super
      home = File.join(ENV["HOME"], "ifolder")
      @local = LocalRepository.new(home)
      @config = Config.new(File.join(home, ".config"))
    end

    desc "configure", "Configure which ifolder server to use"
    def configure
      unless @config.get(:server).nil?
        say "Warning! Replacing old server URL: #{@config.get(:server)}", Color::YELLOW
      end
      server = ask("Server URL:")
      @config.set(:server, server)
    end
    default_task :configure

    desc "ls", "List files"
    def ls
      login 
      @server.list.each do |ifolder|
        star = @local.exists?(ifolder) ? "*" : " "
        puts star + ifolder.name.ljust(20) + " " + ifolder.description
      end
    end

    desc "download [name]", "Download the ifolder with the given name"
    def download(name)
      login
      ifolder = @server.get(name)
      @local.mkdir(ifolder.name)
      download_recursive(ifolder)
    end

    private
    def download_recursive(folder)
      folder.entries.each do |entry|
        puts entry.path
        if entry.directory?
          @local.mkdir(entry.path)
          download_recursive(entry)
        else
          @local.write_file(entry.path) do |file|
            entry.content do |chunk|
              file.write(chunk)
            end
          end
        end
      end 
    end


    def login
      if @config.get(:credentials).nil?
        username = ask("Username:")
        password = ask("Password:")
        @config.set(:credentials, username: username, password: password)
      end
      @server = RemoteRepository.new(@config)
    end
  end
end
