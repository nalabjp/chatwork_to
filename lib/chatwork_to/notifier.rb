Dir["#{File.dirname(__FILE__)}/notifiers/*.rb"].each do |path|
  require path
end

module ChatworkTo
  class Notifier
    def initialize(notifiers)
      @notifiers = []
      notifiers.each do |notifier|
        name = notifier.delete('name')
        @notifiers << "ChatworkTo::Notifiers::#{name.classify}".constantize.new(notifier)
      end
    end

    def notify(notification)
      @notifiers.each do |notifier|
        notifier.notify(notification)
      end
    end
  end
end
