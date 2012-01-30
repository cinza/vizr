require 'rubygems'
require 'handlebars'
require 'yaml'
require 'uri'

DEBUG = true
context = {}

def include_file(path)
  content = ""
  path = File.expand_path(path, @dir)
  begin 
    File.open(path, "r") do |file|
      content = file.read
    end
  rescue StandardError => e
    if DEBUG
      raise e
    end
  end
  content
end

def render(path)
  content = include_file(path)
  template = Handlebars.compile(content)
  template.call(@context)
end

Handlebars.register_helper(:include) do |path, block|
  include_file(path)
end

Handlebars.register_helper(:render) do |path, block|
  render(path)
end

Handlebars.register_helper(:enc) do |string, block|
  content = string.gsub(" ", "-").gsub(/[^[:alnum:]]/, '').downcase!
end

# actually do stuff

if ARGV.size == 1 && ARGV[0] == "--help"
  puts "ruby build.rb template_path"
elsif ARGV.size >= 1
  inpath = ARGV[0]
  envpath = ARGV[1]

  __dirname = Dir.pwd

  @path = File.expand_path(inpath, __dirname)
  @dir = File.dirname(@path)
  @context = {}
  if envpath
    begin 
      @context = YAML.load_file(File.expand_path(envpath, __dirname))
    rescue StandardError => e
      @context = {}
      if DEBUG
        raise e
      end
    end
  end

  puts render(@path)
end
