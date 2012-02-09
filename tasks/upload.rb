require 'rest_client'
require 'json'

task :upload, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]

  api_key = options['api_key']
  endpoint = options['upload']['endpoint']
  dist_path = File.join(target, options[:filename])

  params = {
    :api_key => api_key,
    :data => File.new(dist_path),
    :accept => :json
  }
  params[:version_files] = "1" if options[:version_files]

  if api_key && endpoint
    response = RestClient.put(endpoint, params)
    project = JSON.parse(response.to_s)

    puts "      Upload #{project['success'] ? "succesful" : "error"}"
    puts "==============================="

    if project['success'] && project['changes'].size > 0
      puts "      Uploaded:"
      if project['changes'][0]['uploaded'].empty?
        puts "      none"
      else
        puts "      #{project['changes'][0]['uploaded'].map { |o| o['key'] }.join("\n      ")}"
      end
      puts ""
      puts "==============================="
      puts "      Removed:"
      if project['changes'][0]['removed'].empty?
        puts "      none"
      else
        puts "      #{project['changes'][0]['removed'].map { |o| o['key'] }.join("\n      ")}"
      end
      puts ""
      puts "==============================="

    else !project['success']
      puts "      Errors:"
      puts "      #{project['errors'].join("\n      ")}"
      puts ""
      puts "==============================="
    end

    puts "      Files:"
    puts "      #{project['base_url']}"
    puts "        #{project['files'].join("\n        ")}"
    puts ""
  else
    puts "\nNeed api_key and upload endpoint to upload"
  end
end
