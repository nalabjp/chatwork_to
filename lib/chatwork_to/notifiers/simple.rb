module ChatworkTo
  module Notifiers
    class Simple
      def initialize(opts = {})
        opts = {'io' => $stdout, 'rotation' => 'weekly'}.merge(opts)
        if opts['io'].is_a?(String)
          opts['io'] = File.expand_path(opts['io'])
          FileUtils.mkdir_p(File.dirname(opts['io']))
          File.open(opts['io'], 'a')
        end
        @logger = Logger.new(opts['io'], opts['rotation'])
        @logger.level = Logger::INFO
      end

      def notify(notification)
        @logger.info(notification)
      end
    end
  end
end
