require "bitbucket_snagger/version"
require "bitbucket_rest_api"
require 'escort'
require 'git'

module BitbucketSnagger
  class BitbucketSnagger < ::Escort::ActionCommand::Base
    def initialize(options, arguments)
      @options = options
      @arguments = arguments

      @username   = @options[:global][:options][:username]
      @password   = @options[:global][:options][:password]
      @base_url   = @options[:global][:options][:base_url]
      @project    = @options[:global][:options][:project]
      @repo       = @options[:global][:options][:repo]
      @upstream   = @options[:global][:options][:upstream]

      Escort::Logger.output.puts "loggin in to bitbucket..."
      @bitbucket = BitBucket.new basic_auth: "#{@username}:#{@password}"
      Escort::Logger.output.puts "...done!"
    end

    def repo_exists?(project, repo)
      status = @bitbucket.repos.get project, repo
      Escort::Logger.output.puts "#{project}/#{repo} status: #{status}"
    end

    def create_repo(project, repo, upstream)
      description = "fixme, add a description"
      if ! repo_exists?(project, repo)
        Escort::Logger.output.puts "Creating #{project}/#{repo}"
        @bitbucket.repos.create(
          name=repo,
          description=description,
          website="https://bitbucket.com",
          is_private=false,
          has_issues=false,
          has_wiki=true
        )
      end
    end


    def sync_repo()
      # local scope the instance variables instead of changing scope - maybe
      # I will do something cooler here one day..
      repo = @repo
      project = @project
      base_url = @base_url
      upstream = @upstream

      # create repo on bitbucket server if needed
      create_repo(project, repo, upstream)

      # checkout the repo as a regular git repo using git api for ruby
      Escort::Logger.output.puts "Updating #{repo}..."
      bb_checkout_url = "#{base_url}/#{project}/#{repo}.git"
      working_dir = Dir.mktmpdir
      g = Git.clone(bb_checkout_url, repo, :path => working_dir)

      # add a remote for upstream
      r = g.add_remote('upstream', upstream)

      # sync our forks master branch
      Escort::Logger.output.puts "...pulling changes from #{upstream}"
      g.pull('upstream', 'master')

      # push changes back to master
      Escort::Logger.output.puts "...pushing changes to bitbucket"
      g.push('origin', 'master')

      # example of how to set name and email if commits are being refused
      # g.config('user.name', 'Scott Chacon')
      # g.config('user.email', 'email@email.com')
      Escort::Logger.output.puts "...All done, cleaning up!"
      FileUtils.rm_rf working_dir
    end
  end
end
