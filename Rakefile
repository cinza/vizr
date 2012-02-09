task :install => ["/usr/local/bin/vizr"] do
  puts "install bundler"
  sh "sudo gem install bundler"

  puts "add gems with bundler"
  sh "bundle install"

  puts "install juicer dependencies"
  sh "juicer install yui_compressor"
  sh "juicer install jslint"
end

file "/usr/local/bin/vizr" do
  executable = File.join(File.dirname(__FILE__), "bin", "vizr")
  link = "/usr/local/bin/vizr"
  ln_sf(executable, link)
  puts "vizr linked to /usr/local/bin/vizr"
end
