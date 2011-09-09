task :install => ["/usr/local/bin/vizr"] do
  puts "install handlebars gem"
  sh "sudo gem install hbs"

  puts "install juicer"
  sh "sudo gem install juicer"

  puts "install juicer dependencies"
  sh "juicer install"
end

file "/usr/local/bin/vizr" do
  executable = File.join(File.dirname(__FILE__), "bin", "vizr")
  link = "/usr/local/bin/vizr"
  ln_sf(executable, link)
  puts "vizr linked to /usr/local/bin/vizr"
end
