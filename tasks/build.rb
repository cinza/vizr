NODE_VERSION = "0.6.18"
NODE_VERSION_FILTER = /v0\.6.*/

JS_DIR = "js"
CONFIG_DIR = "config"
VENDOR_DIR = "vendor"

JSHINTRC_FILE = ".jshintrc"
REQUIRE_JS_BUILD_FILE = "require.build.js"

load File.join(VIZR_ROOT, "lib", "parse_hbs.rb")

task :build, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  if options[:watch]

    puts "\nWatching project for changes..."

    rebuild = Proc.new do |base, relative|
      puts "Updated #{File.join(base, relative)}"

      watched_build(target, options)
    end

    # Run the first build
    watched_build(target, options)

    # Watch for changes
    #Listen.to(File.join(File.join(target, "dev"))) do |modified, added, removed|
    #  rebuild.call("", "")
    #end
    Listen.to(target, :filter => [%r{^env\.yaml}, %r{^dev\/}]) do |modified, added, removed|
      rebuild.call("", "")
    end
    #Listen.to(target, :filter => %r{^env\.yaml}).change(&rebuild).start
    #Listen.to(File.join(target, "dev")).change(&rebuild).start

    #FSSM.monitor(target, ["dev/**/*", "env.yaml"], :directories => true) do
    #  update {|base, relative| rebuild.call(base, relative)}
    #  create {|base, relative| rebuild.call(base, relative)}
    #  delete {|base, relative| rebuild.call(base, relative)}
    #end

  else # single build / no watching

    single_build(target, options)

  end
end

def watched_build(target, options)
  [ :create_working_directory,
    :output_package_config,
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
    :output_package_config,
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

  # TODO: Make recursive
  # Follow package symlinks and flatten them into working dir
  tmp_packages = File.join(tmp, "packages")
  if File.exists?(tmp_packages)
    Dir.glob(File.join(tmp_packages, "*")) { |package|
      package_realpath = Pathname.new(package).realpath
      rm_rf(package)
      mkdir_p(package)
      Dir.glob(File.join(package_realpath, "*")) { |file|
        cp_r(file, package)
      }
    }
  end
end

task :output_package_config, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)

  dev_packages = File.join(dev, "packages")
  tmp_js_config = File.join(tmp, "js", "config")
  if File.exists?(tmp_js_config)
    packages = Dir.glob(File.join(dev_packages, "*")).map { |package| 
      File.basename(package)
    }

    Dir.glob(File.join(VIZR_ROOT, "templates", "require.*.js.hbs")) { |template|
      File.open(File.join(tmp_js_config, File.basename(template, ".hbs")), "w") { |file|
        file.puts(render(template, :context => packages))
      }
    }

    Dir.glob(File.join(VIZR_ROOT, "templates", "require.*.js.erb")) { |template|
      File.open(File.join(tmp_js_config, File.basename(template, ".erb")), "w") { |file|
        file.puts(ERB.new(File.read(template)).result(binding))
      }
    }
    
    Dir.glob(File.join(VIZR_ROOT, "templates", "*.css.hbs")) { |template|
      File.open(File.join(tmp, "css", File.basename(template, ".hbs")), "w") { |file|
        file.puts(render(template, :context => packages))
      }
    }
  end
end

task :process_files, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]
  minify = options[:minify]
  jslint = options[:jslint]
  merge = options[:merge]
  jopts = ''

  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  # Check if project is jshint-enabled
  found_jshint_file = File.exists?(File.join(target, JSHINTRC_FILE))

  # If .jshintrc, use jshint and uglify, else use jslint and yui via juicer
  run_jshint = jslint && found_jshint_file
  run_jslint = jslint && !found_jshint_file
  run_uglify_js = minify && found_jshint_file
  run_yui_js = minify && !found_jshint_file

  # Produce require.js build file if template
  requirejs_build_template = File.join(tmp, JS_DIR, CONFIG_DIR, REQUIRE_JS_BUILD_FILE + ".hbs")
  requirejs_build_file = File.join(tmp, JS_DIR, CONFIG_DIR, REQUIRE_JS_BUILD_FILE)
  if File.exists?(requirejs_build_template)
    File.open(requirejs_build_file, "w") { |file|
      file.puts(render(requirejs_build_template, :dir => tmp))
    }
  end

  # Check if project uses require.js
  found_requirejs_build_file = File.exists?(requirejs_build_file)

  run_juicer_merge = !found_requirejs_build_file
  run_requirejs_optimizer = merge && found_requirejs_build_file

  if run_jshint
    setup_jshint

    puts "Running jshint..."
    sh "(cd #{tmp}; jshint .)"
  end

  if !run_yui_js
    jopts << ' -m none'
  end

  if !run_jslint
    jopts << ' -s'
  end

  if !Dir.glob(File.join(tmp, "**", "*.styl")).empty?
    setup_stylus

    sh "stylus #{Dir.glob(File.join(tmp, "**", "*.styl")).join(" ")}"
  end

  if File.exist?(File.join(tmp, "css"))
    if run_juicer_merge
      puts "Running juicer on CSS..."
      Dir.glob(File.join(tmp, "css", "*.css")) do |item|
        sh "juicer merge -i #{jopts} #{item}"
        mv(item.gsub('.css', '.min.css'), item, :force => true)
      end
    end
  end

  if File.exist?(File.join(tmp, "js"))
    if !Dir.glob(File.join(tmp, "**", "*.coffee")).empty?
      setup_coffee_script

      Dir.glob(File.join(tmp, "**", "*.coffee")) do |item|
        sh "coffee -c #{item}"
      end
    end

    if run_juicer_merge
      puts "Running juicer on JS..."
      Dir.glob(File.join(tmp, "js", "*.js")) do |item|
        sh "juicer merge -i #{jopts} #{item}"
        mv(item.gsub('.js', '.min.js'), item, :force => true)
      end
    end

    if run_requirejs_optimizer
      setup_requirejs

      puts "Running RequireJS optimizer on JS & CSS..."
      sh "r.js -o #{requirejs_build_file}"
    end

    if run_uglify_js
      setup_uglify_js

      Dir.glob(File.join(tmp, "js", "*.js")) do |item|
        puts "Running uglify-js on #{item}..."
        sh "uglifyjs #{item} > #{item}.min"
        mv(item.gsub('.js', '.js.min'), item, :force => true)
      end
    end
  end

  puts "Applying env.yaml settings..."
  Dir[File.join(tmp, "*.hbs")].each do |hbs|
    sh "ruby #{File.join(VIZR_ROOT, "lib", "parse_hbs.rb")} \"#{hbs}\" #{File.join(target, "env.yaml")} > #{File.join(tmp, File.basename(hbs, ".hbs"))}"
  end
end

def setup_requirejs
  install_npm_package("requirejs", "2.0.1")
end

def setup_uglify_js
  install_npm_package("uglify-js", "1.2.6")
end

def setup_jshint
  install_npm_package("jshint", "0.7.1")
end

def setup_stylus
  install_npm_package("stylus", "0.27.1")
end

def setup_coffee_script
  install_npm_package("coffee-script", "1.3.3")
end

def install_npm_package(package, version)
  if !node?
    node_missing
  end

  root_package_path = ""
  IO.popen("npm root -g") { |io|
    root_package_path = io.read[0..-2]
  }

  search_path = "#{root_package_path}/#{package}:#{package}@#{version}"

  IO.popen("npm ll -g --parseable") { |io|
    io.each { |line|
      if line.include?(search_path)
        return # Found package
      end
    }
  }

  install_prefix = ""
  if !File.writable?(root_package_path)
    install_prefix = "sudo "
  end

  IO.popen("#{install_prefix}npm install -g #{package}@#{version}") { |io|
    io.read
  }
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
  message("nodejs_dependency", {
    :node_version => NODE_VERSION
  })
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

  ["css", "js", "img", "fonts", "templates", "packages"].each do |folder|
    if File.exists?(File.join(tmp, folder))
      mkdir_p(File.join(build, folder))
      cp_r(File.join(tmp, folder), build)
    end
  end

  cp(Dir[File.join(tmp, "*.html")], build)
  cp(Dir[File.join(tmp, "*.manifest")], build)

  sh "ruby #{File.join(VIZR_ROOT, "lib", "cachepath.rb")} \"#{build}\" \"#{File.join(build, "**", "*")}\" > #{File.join(build, "js", "cachepath.js")}"
end

task :clean_up, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  rm_rf(tmp)

  puts "Build completed at #{Time.now}"
end
