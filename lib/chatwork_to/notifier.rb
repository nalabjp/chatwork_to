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

    def notify(messages)
      messages = Array[*messages]
      @notifiers.each do |notifier|
        messages.each do |msg|
          notifier.notify(msg)
        end
      end
    end
  end
end
