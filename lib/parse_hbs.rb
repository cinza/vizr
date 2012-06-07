require 'rubygems'
require 'handlebars'
require 'yaml'
require 'uri'

DEBUG = true
@handlebars = Handlebars::Context.new

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

def render(path, context = @context)
  content = include_file(path)
  template = @handlebars.compile(content)
  template.call(context)
end

@handlebars.register_helper(:include) do |this, path, block|
  include_file(path)
end

@handlebars.register_helper(:render) do |this, path, block|
  render(path)
end

@handlebars.register_helper(:enc) do |this, string, block|
  content = string.gsub(/[^[:alnum:][:space:]]/, '').gsub(" ", "-").downcase
end

# actually do stuff

if __FILE__ == $0
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
end
