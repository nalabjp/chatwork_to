module ChatworkTo
  class Config
    attr_accessor :chatwork_id, :chatwork_pass, :notifiers

    def initialize(opts)
      require_options!(opts)
      @chatwork_id = opts['chatwork']['id']
      @chatwork_pass = opts['chatwork']['pass']
      @notifiers = Array[*opts['notifiers']]
    end

  private
    def require_options!(opts)
      raise InvalideConfiguration if opts['chatwork'].blank?
      raise InvalideConfiguration if opts['chatwork']['id'].blank?
      raise InvalideConfiguration if opts['chatwork']['pass'].blank?
      raise InvalideConfiguration if opts['notifiers'].blank?
    end

    class << self
      def load(yaml = nil)
        conf_hash = load_yaml(yaml)
        new(conf_hash) if conf_hash.present?
      end

    private
      def default_confs
        %w( ./ ~/ ).map{ |dir| dir.concat('chatwork_to.yml') }
      end

      def load_yaml(yaml = nil)
        default_confs.unshift(yaml).compact.each do |yml|
          config = YAML.load_file(yml) rescue nil
          return config unless config.nil?
        end
        nil
      end
    end
  end

  class InvalideConfiguration < StandardError; end;
end
