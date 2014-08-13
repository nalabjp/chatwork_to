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

    def notify(hash)
      @notifiers.each { |n| n.notify(hash) }
    end

    def info(message)
      @notifiers.each { |n| n.info(message) }
    end
  end
end
