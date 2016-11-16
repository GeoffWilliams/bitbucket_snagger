require "bitbucket_snagger/version"
#require "bitbucket_rest_api"
require 'escort'
require 'json'
require 'rest-client'

module BitbucketSnagger
  class BitbucketSnagger < ::Escort::ActionCommand::Base
    def initialize(options, arguments)
      @options = options
      @arguments = arguments

      @insecure       = @options[:global][:options][:insecure]
      @username       = @options[:global][:options][:username]
      @password       = @options[:global][:options][:password]
      @base_url       = @options[:global][:options][:base_url]
      @projectKey     = @options[:global][:options][:project]
      @repositorySlug = @options[:global][:options][:repo]
      @upstream       = @options[:global][:options][:upstream]

    end

    def get_url(cmd)
      if @insecure
        schema = "http"
      else
        schema = "https"
      end
      "#{schema}://#{@username}:#{@password}@#{@base_url}#{cmd}"
    end

    def get_clone_url()
      if @insecure
        schema = "http"
      else
        schema = "https"
      end
      "#{schema}://#{@username}:#{@password}@#{@base_url}/scm/#{@projectKey}/#{@repositorySlug}.git"
    end

    def repo_exists?(projectKey, repositorySlug)
      # https://developer.atlassian.com/static/rest/bitbucket-server/4.11.0/bitbucket-rest.html#idp3793920
      url = get_url("/rest/api/1.0/projects/#{projectKey}/repos/#{repositorySlug}")
      status = false
      begin
        response = RestClient.get url, {accept: :json}
        if response.code == 200
          status = true
        end
      rescue RestClient::Exception => e
        Escort::Logger.output.puts "[WARN] #{e.message}: #{projectKey}/#{repositorySlug}"
      end
      Escort::Logger.output.puts "#{projectKey}/#{repositorySlug} status: #{status}"
      status
    end

    def create_repo(projectKey, repositorySlug, upstream)
      description = "fixme, add a description"
      if ! repo_exists?(projectKey, repositorySlug)
        Escort::Logger.output.puts "Creating new repository on bitbucket server: #{projectKey}/#{repositorySlug}"
        # https://developer.atlassian.com/static/rest/bitbucket-server/4.11.0/bitbucket-rest.html#idp3769760

        url = get_url("/rest/api/1.0/projects/#{projectKey}/repos")
        begin
          payload = {
            'name'  => repositorySlug,
            'scmId' => 'git'
          }
          response = RestClient.post url, payload.to_json, {accept: :json, content_type: :json}
          if response.code == 201
            status = true
          end
        rescue RestClient::Exception => e
          Escort::Logger.output.puts "#{e.message}: #{url}"
        end
      end
    end


    def sync_repo()
      # local scope the instance variables instead of changing scope - maybe
      # I will do something cooler here one day..
      repositorySlug = @repositorySlug
      projectKey = @projectKey
      base_url = @base_url
      upstream = @upstream

      # create repo on bitbucket server if needed
      create_repo(projectKey, repositorySlug, upstream)

      # checkout the repo as a regular git repo using git api for ruby
      url = get_clone_url()

      working_dir = Dir.mktmpdir
      Escort::Logger.output.puts "updating #{repositorySlug} from #{upstream} in #{working_dir}..."
      %x(
        git clone #{url} #{working_dir} && \
        cd #{working_dir} && \
        git remote add upstream #{upstream} && \
        git pull upstream master && \
        git push origin master --tags
      )
      Escort::Logger.output.puts "...All done, cleaning up!"
      FileUtils.rm_rf working_dir

    end
  end
end
