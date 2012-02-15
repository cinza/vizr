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

    # considered writable if there is not a lock file
    # or the contents of the lock file == the project root
    def writable?
      if @writable == nil
        path = locked_to_path
        @writable = !path || path == @root
      end

      @writable
    end

    def locked?
      !writable?
    end

    # reset lock by replacing value with
    # the current project's root
    def reset_lock
      locked_to_path = @root
      @writable = true
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

    def locked_to_path=(path)
      File.open(lockfile, "w") do |f|
        f.write(@root)
      end

      # reset writable. by doing this
      # we will recheck later
      @writable = nil
    end

    def locked_to_path
      if File.exists?(lockfile)
        File.read(lockfile).strip
      else
        nil
      end
    end

  end
end
