require 'handlebars'
require 'optparse'

module Vizr
  class Cli

    @@commands = {}

    def initialize(vizr_root, working_dir)
      @vizr = Vizr.new(vizr_root)
      @working_dir = working_dir
      @commands = @@commands
    end

    def parse(args)
      cmd = args[0].to_sym rescue nil
      args = args[1..-1] || []

      command(cmd || :help, args)
    end

    def command(cmd, args)
      command = @commands[cmd] || @commands[:help]
      options = {
        :check_if_project => true,
        :check_for_updates => true,
        :check_if_locked => true,
        :parse_options => true
      }.update(command.options)

      if options[:parse_options]
        command.opts.on_tail("-h", "--help", "Show this message") do
          puts command.opts
          exit
        end

        command.opts.parse!(args)
      end

      check_for_updates() if options[:check_for_updates]

      project_path = args[0]
      if project_path
        project_path = File.expand_path(project_path, @working_dir)

        project = @vizr.project(project_path)

        cont = (!options[:check_if_project] ||  project.exists?) && (!options[:check_if_locked] || project.locked?)

        if cont
          command.run(project, args)
        end
      elsif options[:parse_options]
        puts command.opts
      else
        help()
      end
    end

    # I hate this class
    public
    class Command
      attr :name
      attr :description
      attr :options
      attr :opts

      def initialize(name, description, options = {}, &block)
        @name = name
        @description = description
        @options = options
        @opts = OptionParser.new

        block.call(self)
      end

      def exec(&block)
        @exec = block
      end

      def run(project, args)
        if @exec
          @exec.call(project, args)
        end
      end
    end

    protected

    def self.on(name, description, options = {}, &block)
      @@commands[name.to_sym] = Command.new(name, description, options) do |command|
        block.call(command)
      end
    end

    def help(command = nil)
      # handles case when someone enters in "vizr help <command>"
      if command
        command(command.to_sym, ["-h"])
        exit
      end

      # max spaces to show between command and description
      spaces = 10

      # output info
      puts "usage: vizr <command> [<args>]\n\n"
      puts "vizr commands are:"
      @commands.values.map do |command|
        [command.name.to_s, command.description]
      end.each do |cmd|
        puts "   #{cmd[0]}#{" " * (spaces - cmd[0].length)}#{cmd[1]}"
      end
      puts "\nSee 'vizr help <command>' for more information on a specific command"
    end

    private

    on(:create, "create a new vizr project", :check_if_project => false) do |command|
      options = {}
      command.opts.banner = "usage: vizr create [args] <projectpath>"
     
      command.opts.on("-t", "--type TYPE", [:basic], "Predefined project type (basic only offered now)") do |type|
        options[:type] = type.to_sym
      end

      command.exec do |project|
        if project.exists?
          message(:projects_exists)
        else
          project.create(options)
        end
      end
    end

    on(:build, "build a vizr project") do |command|
      options = {}
      command.opts.banner = ""

      command.exec do |project|
        project.build(options)
      end
    end

    on(:dist, "zip up the contents of a project's build folder") do |command|
      options = {}
      command.opts.banner = "usage: vizr dist [args] <projectpath>"

      command.opts.on("-n", "--filename [NAME]", "File name of zip (default: dist.zip)") do |filename|
        options[:filename] = filename
      end

      command.exec do |project|
        project.dist(options)
      end
    end

    on(:upload, "upload a project zip to a server") do |command|
      options = {}
      command.opts.banner = "usage: vizr upload [args] <projectpath>"
      command.opts.on("-n", "--filename [NAME]", "File name of zip (default: dist.zip)") do |filename|
        options[:filename] = filename
      end

      command.opts.on("--[no-]version", "Version files (versioning allows web browsers to cache content)") do |version|
        options[:version_files] = version
      end

      command.exec do |project|
        project.upload(options)
      end
    end

    on(:pull, "update vizr builder to newest version") do |command|
      options = {}
      command.opts.banner = ""

      command.exec do |project|

      end
    end

    on(:help, "this information", :parse_options => false, :check_if_project => false) do |command|
      command.exec do |project, args|
        help(args[0])
      end
    end 

    def message(name, context = {})
      path = File.join("messages", "#{name.to_s}.hbs")
      path = File.expand_path(path, @vizr.root)
      content = File.read(path)

      template = Handlebars.compile(content)
      puts ""
      puts template.call(context)
      puts ""
    end

    def check_for_updates
      elasped_time = Time.now.to_i - @vizr.last_checked_for_update_at.to_i

      # check every 30min
      make_check = elasped_time > 30 * 60 # 30m * 60s = 30 minutes in seconds

      if make_check
        puts "checking for updates..."
        if @vizr.updated?
          message(:out_of_date, {
            :commits => @vizr.new_updates
          })
        else
          puts "already up to date"
          @vizr.last_checked_for_update_at = Time.now
        end
      end
    end

  end
end
