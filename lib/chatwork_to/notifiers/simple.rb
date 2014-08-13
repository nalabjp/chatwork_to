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
        @logger.level = Logger::DEBUG
      end

      def notify(hash)
        @logger.debug({chat_list: hash['chat_list'], room: hash['room']}.inspect)
      end

      def info(message)
        @logger.info(message)
      end
    end
  end
end
