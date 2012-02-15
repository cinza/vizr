require "grit"
require "vizr/vizr_config"

module Vizr
  class Vizr

    USER_FILE = "~/.vizrrc"
    LAST_UPDATE_CHECK_FILE = ".last_update_check"

    attr :root

    def initialize(root)
      @root = root
    end

    def project(root)
      Project.new(self, root)
    end

    def updated?
      repo = Grit::Repo.new(@root)

      branch = repo.head.name
      repo.remote_fetch('origin')
      local_rev = repo.git.rev_list({ :max_count => 1 }, branch)
      remote_rev = repo.git.rev_list({ :max_count => 1 }, "origin/#{branch}")

      # making some assumptions here
      local_rev != remote_rev
    end

    def new_updates
      repo = Grit::Repo.new(@root)

      branch = repo.head.name
      local_rev = repo.git.rev_list({ :max_count => 1 }, branch)
      remote_rev = repo.git.rev_list({ :max_count => 1 }, "origin/#{branch}")

      commits = repo.commits_between(local_rev, remote_rev).map do |commit|
        "#{commit.short_message} (#{commit.author})"
      end

      commits
    end

    def update!(opts = {})
      puts "update this"
    end

    def config
      @config ||= VizrConfig.from_yaml(userfile)
    end

    def userfile
      File.expand_path(@root, USER_FILE)
    end

    def last_checked_for_update_at
      if File.exists?(last_update_check_file)
        begin
          at = Time.at(File.read(last_update_check_file).strip.to_i)
        rescue
          at = nil
        end
      end

      at || Time.at(0)
    end

    def last_checked_for_update_at=(at)
      File.open(last_update_check_file, "w") do |f|
        f.write(at.to_i.to_s)
      end
    end

    def last_update_check_file
      File.join(@root, LAST_UPDATE_CHECK_FILE)
    end

  end
end
