task :package, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]
  
  cd File.join(target, "build")
  sh "zip -r ../#{options[:filename]} ."
end
