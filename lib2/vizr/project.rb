module Vizr
  class Project

    DOT_FILE = ".vizr"
    POSSIBLE_DOT_FILES = [DOT_FILE, ".vizer"]

    LOCK_FILE = ".vizr-lock"
    POSSIBLE_LOCK_FILES = [LOCK_FILE, ".vizer-lock"]

    attr :vizr
    attr :root

    def initialize(vizr, root)
      @vizr = vizr
      @root = root
    end

    def create(opts)
      puts "create"
    end

    def build(opts)
      puts "build"
      #Builder.new(self, opts)
    end

    def dist(opts)
      puts "dist"
      #Dist.new(self, opts)
    end

    def upload(opts)
      puts "upload"
    end

    def config
      @config ||= ProjectConfig.from_yaml(dotfile)
    end

    def valid?
      exists? && !locked?
    end

    def exists?
      File.exists?(dotfile)
    end

    def dotfile
      if @dotfile
        return @dotfile
      end
      
      @dotfile = POSSIBLE_DOT_FILES.map do |file|
        File.join(@root, file)
      end.find do |path|
        File.exists?(path)
      end || File.join(@root, DOT_FILE)
    end

    # considered locked if there exists a lock file
    # and its contents do not equal the @root
    def locked?
      if @locked == nil
        @locked = !File.exists?(lockfile) || File.read(lockfile).strip != @root
      end

      @locked
    end

    # reset lock by replacing value with
    # the current vulues root
    def reset_lock
      File.open(lockfile, "w") do |f|
        f.write(@root)
      end

       @locked = false
    end

    def lockfile
      if @lockfile
        return @lockfile
      end
      
      @lockfile = POSSIBLE_LOCK_FILES.map do |file|
        File.join(@root, file)
      end.find do |path|
        File.exists?(path)
      end || File.join(@root, LOCK_FILE)
    end

  end
end
