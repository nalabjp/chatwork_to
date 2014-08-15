module ChatworkTo
  class Config
    attr_reader :chatwork_email, :chatwork_pass, :rooms, :notifiers

    def initialize(opts)
      require_options!(opts)
      @chatwork_email = opts['chatwork']['email']
      @chatwork_pass  = opts['chatwork']['pass']
      @rooms          = Array[*opts['chatwork']['rooms']].map(&:to_s)
      @notifiers      = Array[*opts['notifiers']]
    end

  private
    def require_options!(opts)
      raise InvalideConfiguration, 'Require configureation: chatwork'       if opts['chatwork'].blank?
      raise InvalideConfiguration, 'Require configureation: chatwork.email' if opts['chatwork']['email'].blank?
      raise InvalideConfiguration, 'Require configureation: chatwork.pass'  if opts['chatwork']['pass'].blank?
      raise InvalideConfiguration, 'Require configureation: chatwork.rooms' if opts['chatwork']['rooms'].blank?
      raise InvalideConfiguration, 'Require configureation: notifiers'      if opts['notifiers'].blank?
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
          config = YAML.load_file(File.expand_path(yml)) rescue nil
          return config unless config.nil?
        end
        nil
      end
    end
  end

  class InvalideConfiguration < StandardError; end;
end
