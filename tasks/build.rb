NODE_VERSION = "0.6.18"
NODE_VERSION_FILTER = /v0\.6.*/

JSHINTRC_FILE = ".jshintrc"

task :build, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  if options[:watch]

    puts "\nWatching project for changes..."

    last_change_time = Time.now.to_f

    rebuild = lambda { |base, relative|
      puts "Updated #{File.join(base, relative)}"

      time_since_build = Time.now.to_f - last_change_time

      puts "#{time_since_build} seconds since last build"

      # only run tasks if we have not run the tasks in the last second
      # this tries to prevent multiple builds when > 1 file updates simultaneously
      if time_since_build >= 1.0
        watched_build(target, options)
        last_change_time = Time.now.to_f
      else
        puts "Last build less than 1 seconds ago, skipping"
      end
    }

    # Run the first build
    watched_build(target, options)

    # Watch for changes
    FSSM.monitor(target, ["dev/**/*", "env.yaml"], :directories => true) do
      update {|base, relative| rebuild.call(base, relative)}
      create {|base, relative| rebuild.call(base, relative)}
      delete {|base, relative| rebuild.call(base, relative)}
    end

  else # single build / no watching

    single_build(target, options)

  end
end

def watched_build(target, options)
  [ :create_working_directory,
    :process_files,
    :create_build_directory,
    :move_to_build,
    :clean_up
  ].each do |task|
    Rake::Task[task].reenable
    begin
      Rake::Task[task].invoke(target, options)
    rescue
      puts "ERROR: Build failed to complete, continuing to watch for changes"
      break
    end
  end
end

def single_build(target, options)
  [ :create_working_directory,
    :process_files,
    :create_build_directory,
    :move_to_build,
    :clean_up
  ].each do |task|
    Rake::Task[task].invoke(target, options)
  end
end

task :create_working_directory, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  rm_rf(tmp)
  cp_r(dev, tmp)
end

task :process_files, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]
  minify = options[:minify]
  jslint = options[:jslint]
  jopts = ''

  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  # Check if project is jshint-enabled
  found_jshint_file = File.exists?(File.join(target, JSHINTRC_FILE))
  run_jshint = jslint && found_jshint_file
  run_jslint = jslint && !found_jshint_file

  if run_jshint
    setup_jshint

    puts "Running jshint..."
    sh "(cd #{tmp}; jshint .)"
  end

  if !minify
    jopts << ' -m none'
  end

  if !run_jslint
    jopts << ' -s'
  end

  if File.exist?(File.join(tmp, "css"))
    puts "Running juicer on CSS..."
    Dir.glob(File.join(tmp, "css", "*.css")) do |item|
      sh "juicer merge -i #{jopts} #{item}"
      mv(item.gsub('.css', '.min.css'), item, :force => true)
    end
  end

  if File.exist?(File.join(tmp, "js"))
    puts "Running juicer on JS..."
    Dir.glob(File.join(tmp, "js", "*.js")) do |item|
      sh "juicer merge -i #{jopts} #{item}"
      mv(item.gsub('.js', '.min.js'), item, :force => true)
    end
  end

  puts "Applying env.yaml settings..."
  Dir[File.join(tmp, "*.hbs")].each do |hbs|
    sh "ruby #{File.join(VIZR_ROOT, "lib", "parse_hbs.rb")} \"#{hbs}\" #{File.join(target, "env.yaml")} > #{File.join(tmp, File.basename(hbs, ".hbs"))}"
  end
end

def setup_jshint
  if !node?
    node_missing
  end

  if !which?("jshint")
    sh "npm install -g jshint"
  end
end

def node?
  # First test if node exists at all
  if !which?("node")
    return false
  end

  # Is it an acceptable version?
  version = ""
  IO.popen("node --version") { |io|
    version = io.read
  }

  if !(version =~ NODE_VERSION_FILTER)
    return false
  end

  return true
end

def which?(program)
  IO.popen("which #{program}") { |io|
    io.read
  }

  if !$?.exitstatus.zero?
    return false
  end

  return true
end

def node_missing
  puts "############################### ERROR ###############################"
  puts "# This project requires Node.js #{NODE_VERSION} to build.                    #"
  puts "#                                                                   #"
  puts "# Option 1: Use Vagrant and run from there: http://git.io/q0xYy     #"
  puts "# Option 2: Install node in three easy steps:                       #"
  puts "#   $ wget -O ~/bin/nave http://git.io/q3EXrg                       #"
  puts "#     (assumes ~/bin in PATH)                                       #"
  puts "#   $ chmod a+x ~/bin/nave                                          #"
  puts "#   $ nave usemain #{NODE_VERSION}                                           #"
  puts "#####################################################################"
  exit
end

task :create_build_directory, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  # remove only build folder contents, not the folder
  # prevents weird file descriptor issue if directly serving directory
  rm_rf(Dir[File.join(build, "*")])

  # create directory if it doesn't exist
  mkdir_p(build)
end

task :move_to_build, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]

  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  ["css", "js", "img", "fonts"].each do |folder|
    if File.exists?(File.join(tmp, folder))
      mkdir_p(File.join(build, folder))
      cp_r(File.join(tmp, folder), build)
    end
  end

  cp(Dir[File.join(tmp, "*.html")], build)
  cp(Dir[File.join(tmp, "*.manifest")], build)

  if options[:make_cache_path_file]
     sh "ruby #{File.join(VIZR_ROOT, "lib", "cachepath.rb")} \"#{build}\" \"#{File.join(build, "**", "*")}\" > #{File.join(build, "js", "cachepath.js")}"
  end
end

task :clean_up, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  rm_rf(tmp)
end
