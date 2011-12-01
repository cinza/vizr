task :build, :target, :options do |t, args|
  [ :create_working_directory,
    :process_files,
    :create_build_directory,
    :move_to_build,
    :clean_up
  ].each do |task|
    options = args[:options]
    Rake::Task[task].invoke(args[:target])
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

task :process_files, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  sh "juicer merge -i #{File.join(tmp, "css", "main.build.css")} #{File.join(tmp, "css", "main.css")}"
  mv(File.join(tmp, "css", "main.min.css"), File.join(tmp, "css", "main.css"), :force => true)
  
  sh "juicer merge -i #{File.join(tmp, "css", "main.build.js")} #{File.join(tmp, "js", "main.js")}"
  mv(File.join(tmp, "js", "main.min.js"), File.join(tmp, "js", "main.js"), :force => true)

  Dir[File.join(tmp, "*.hbs")].each do |hbs|
    sh "ruby #{File.join(VIZER_ROOT, "lib", "parse_hbs.rb")} \"#{hbs}\" #{File.join(target, "env.yaml")} > #{File.join(tmp, File.basename(hbs, ".hbs"))}"
  end
end

task :create_build_directory, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  rm_rf(build)
  mkdir(build)
end

task :move_to_build, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  ["css", "js", "img"].each do |folder|
    if File.exists?(File.join(tmp, folder))
      mkdir_p(File.join(build, folder))
      
      if folder == "css"
        cp(File.join(tmp, folder, "main.css"), File.join(build, folder))
      elsif folder == "js"
        cp(File.join(tmp, folder, "modernizr.js"), File.join(build, folder))
        cp(File.join(tmp, folder, "jquery.js"), File.join(build, folder))
        cp(File.join(tmp, folder, "main.js"), File.join(build, folder))
      else
        cp_r(File.join(tmp, folder), build)
      end
    end 
  end
  
  cp(Dir[File.join(tmp, "*.html")], build)
end

task :clean_up, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  rm_rf(tmp)
end
