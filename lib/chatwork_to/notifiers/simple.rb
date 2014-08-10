module ChatworkTo
  module Notifiers
    class Simple
      def initialize(opts)
      end

      def notify(msg)
        puts msg.inspect
      end
    end
  end
end
