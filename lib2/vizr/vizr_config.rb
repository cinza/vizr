require 'yaml'

module Vizr

  class VizrConfig

    attr :api_key

    def initialize(conf = {})
      @api_key = conf[:api_key]
    end

    def self.from_yaml(path)
      conf = {}
      if File.exists?(path)
        conf = Yaml.load(path)
        conf = conf.is_a?(Hash) ? conf : {}
      end

      VizrConfig.new(conf)
    end

  end

end
