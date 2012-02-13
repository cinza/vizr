require 'yaml'

module Vizr
  class ProjectConfig
    attr :upload

    def initialize(conf = {})
      @upload = ProjectUploadConfig.new(conf[:upload])
    end

    def self.from_yaml(path)
      conf = {}
      if File.exists?(path)
        conf = Yaml.load(path)
        conf = conf.is_a?(Hash) ? conf : {}
      end

      VizrConfig.new(conf)
    end

    private

    class ProjectUploadConfig
      attr :endpoint

      def initialize(conf = {})
        @endpoint = conf[:endpoint]
      end
    end
  end
end

