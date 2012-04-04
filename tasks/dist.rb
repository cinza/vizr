task :package, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]
  
  cd File.join(target, "build")
  filename = "../#{options[:filename]}"
  rm_f(filename) # remove filename if it exists (repacking has caused issues)
  sh "zip -r #{filename} ."
end
