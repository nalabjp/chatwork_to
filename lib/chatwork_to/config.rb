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
      raise InvalidConfiguration, 'Require configuration: chatwork'       if opts['chatwork'].blank?
      raise InvalidConfiguration, 'Require configuration: chatwork.email' if opts['chatwork']['email'].blank?
      raise InvalidConfiguration, 'Require configuration: chatwork.pass'  if opts['chatwork']['pass'].blank?
      raise InvalidConfiguration, 'Require configuration: chatwork.rooms' if opts['chatwork']['rooms'].blank?
      raise InvalidConfiguration, 'Require configuration: notifiers'      if opts['notifiers'].blank?
    end

    class << self
      def load(opts = {})
        conf_hash = load_yaml(opts)
        if conf_hash.present?
          new(conf_hash)
        else
          raise InvalidConfiguration, 'Nothing configuration'
        end
      end

    private
      def default_conf_dirs
        %w( ./ ~/ )
      end

      def load_yaml(opts = {})
        confs = default_conf_dirs
        confs.unshift(opts['dir']) if opts['dir'].present?
        confs.unshift(opts['yaml']) if opts['yaml'].present?

        confs.compact.each do |file_or_dir|
          file_or_dir = File.expand_path(file_or_dir)
          if File.directory?(file_or_dir)
            yml = File.join(file_or_dir, 'chatwork_to.yml')
          else
            yml = file_or_dir
          end
          config = YAML.load(ERB.new(IO.read(File.expand_path(yml))).result) rescue nil
          return config unless config.nil?
        end
        nil
      end
    end
  end

  class InvalidConfiguration < StandardError; end;
end
