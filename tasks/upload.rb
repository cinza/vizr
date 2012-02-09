require 'rest_client'

task :upload, :target, :options do |t, args|
  target = args[:target]
  options = args[:options]

  api_key = ""
  project_url = ""
  dist_path = File.join(target, options[:filename])

  params = {
    :api_key => api_key,
    :data => File.new(dist_path)
  }
  params[:version_files] = "1" if options[:version_files]

  response = RestClient.put(project_url, params)

  puts response.to_s
end
