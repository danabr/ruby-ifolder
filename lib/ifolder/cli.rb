# encoding: utf-8
require 'thor'
require 'ifolder/config'
require 'ifolder/remote/repository'
require 'ifolder/local/repository'

module IFolder
  class CLI < Thor
    def initialize(*args)
      super
      home = File.join(ENV["HOME"], "ifolder")
      @local = Local::Repository.new(home)
      FileUtils.mkdir_p(home)
      @config = Config.new(File.join(home, ".config"))
    end

    desc "configure", "Configure which ifolder server to use"
    def configure
      unless @config[:server].nil?
        say "Warning! Replacing old server URL: #{@config[:server]}", Color::YELLOW
      end
      server = ask("Server domain name or IP:")
      @config[:server] = server
      @config.save
    end
    default_task :configure

    desc "ls", "List ifolders"
    def ls
      login
      @remote.list.each do |ifolder|
        star = @local.exists?(ifolder.name) ? "*" : " "
        puts star + ifolder.name.ljust(20) + " " + ifolder.description
      end
    end

    desc "download [name]", "Download the ifolder with the given name"
    method_options force: :boolean
    def download(name)
      login
      @local.clone(@remote.get(name))
    end

    desc "update [name]", "Fetch updates for the ifolder with the given name"
    def update(name)
      login
      @local.update(@remote.get(name))
    end

    private
    def login
      if @config[:credentials].nil?
        username = ask("Username:")
        password = ask("Password:")
        @config[:credentials] = {username: username, password: password}
        @config.save
      end
      credentials = @config[:credentials]
      @remote = Remote::Repository.new(@config[:server], credentials[:username],
                                        credentials[:password])
    end
  end
end
