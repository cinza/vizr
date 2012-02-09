require 'rest_client'

task :upload, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]

  puts options.inspect

  api_key = options['api_key']
  endpoint = options['upload']['endpoint']
  dist_path = File.join(target, options[:filename])

  params = {
    :api_key => api_key,
    :data => File.new(dist_path)
  }
  params[:version_files] = "1" if options[:version_files]

  if api_key && endpoint
    response = RestClient.put(endpoint, params)
    puts response.to_s
  end
end
