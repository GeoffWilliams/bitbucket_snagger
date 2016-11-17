# Copyright 2016 Geoff Williams for Puppet Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "bitbucket_snagger/version"
#require "bitbucket_rest_api"
require 'escort'
require 'json'
require 'rest-client'

# not inistyle!
require 'inifile'


module BitbucketSnagger
  class BitbucketSnagger < ::Escort::ActionCommand::Base
    def initialize(options, arguments)
      @options = options
      @arguments = arguments

      @credentials    = File.join(ENV['HOME'], '/.bitbucket_snagger.ini')
      load_credentials()
      @projectKey     = @options[:global][:options][:projectKey]
      @repositorySlug = @options[:global][:options][:repositorySlug]
      @upstream       = @options[:global][:options][:upstream]

      # fixme - I'm sure there's a better way to do this...
      if @projectKey.empty?
        raise Escort::UserError.new("Need a value for --projectKey")
      end
      if @repositorySlug.empty?
        raise Escort::UserError.new("Need a value for --repositorySlug")
      end
      if @upstream.empty?
        raise Escort::UserError.new("Need a value for --upstream")
      end
    end

    def load_credentials
      if File.exists?(@credentials)
        # must do a bitwise and to get the permissions bits
        mode = File.stat(@credentials).mode & 0777
        if mode == 0600
          myini = IniFile.load(@credentials, {:default => '__GLOBAL__'})

          # username
          if myini['__GLOBAL__']['username'].empty?
            raise Escort::UserError.new("username not specified in #{@credentials}")
          else
            @username = myini['__GLOBAL__']['username']
          end

          # password
          if myini['__GLOBAL__']['password'].empty?
            raise Escort::UserError.new("password not specified in #{@credentials}")
          else
            @password = myini['__GLOBAL__']['password']
          end

          # base url
          if myini['__GLOBAL__']['schema'].empty?
            raise Escort::UserError.new("schema not specified in #{@credentials}")
          else
            @schema = myini['__GLOBAL__']['schema']
          end

          # base url
          if myini['__GLOBAL__']['base_url'].empty?
            raise Escort::UserError.new("base_url not specified in #{@credentials}")
          else
            @base_url = myini['__GLOBAL__']['base_url']
          end

        else
          raise Escort::UserError.new("Permissions on #{@credentials} are too lax - must be 0600")
        end
      else
        raise Escort::UserError.new("File not found reading credentials at #{@credentials}")
      end
    end

    def get_url(cmd)
      if @schema == 'http'
        Escort::Logger.output.puts "[WARN] Using insecure http access for #{@base_url}"
      end
      "#{@schema}://#{@username}:#{@password}@#{@base_url}#{cmd}"
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
          Escort::Logger.output.puts "#{projectKey}/#{repositorySlug} already exists - will update"
        end
      rescue RestClient::Exception => e
        Escort::Logger.error.error "[WARN] #{e.message}: #{projectKey}/#{repositorySlug}"
      rescue Errno::ECONNREFUSED => e
        # dont continue if server down
        raise Escort::UserError.new("[ERROR] #{e.message} for #{url}")
      end
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
          Escort::Logger.error.error "#{e.message}: #{url}"
        rescue Errno::ECONNREFUSED => e
          raise Escort::UserError.new("[ERROR] #{e.message} for #{url}")
        end
      end
    end

    def logout()
      if File.exits?(@credentials)
        File.delete(@credentials)
        Escort::Logger.output.puts "removed #{@credentials}"
      else
        Escort::Logger.output.puts "already removed #{@credentials}"
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
        git fetch --all && \
        git pull upstream master && \
        git push origin master --tags
      )
      Escort::Logger.output.puts "...All done, cleaning up!"
      FileUtils.rm_rf working_dir

    end
  end
end
