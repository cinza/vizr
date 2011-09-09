task :build, :target do |t, args|
  [ :create_working_directory,
    :process_files,
    :create_build_directory,
    :move_to_build,
    :clean_up
  ].each do |task|
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

  sh "juicer merge -force -o #{File.join(tmp, "css", "main.build.css")} #{File.join(tmp, "css", "main.css")}"
  mv(File.join(tmp, "css", "main.build.css"), File.join(tmp, "css", "main.css"), :force => true)
  sh "ruby #{File.join(VIZER_ROOT, "lib", "parse_hbs.rb")} #{File.join(tmp, "index.html.hbs")} #{File.join(target, "env.yaml")} > #{File.join(tmp, "index.html")}"

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
    mkdir_p(File.join(build, folder))
    cp_r(File.join(tmp, folder), build)
  end
  cp(Dir[File.join(tmp, "*.html")], build)
  cp(Dir[File.join(tmp, "*.js")], build)
end

task :clean_up, :target do |t, args|
  target = args[:target]
  dev = File.expand_path(DEV_PATH, target)
  tmp = File.expand_path(TMP_PATH, target)
  build = File.expand_path(BUILD_PATH, target)

  rm_rf(tmp)
end
