module ChatworkTo
  class Process
    CONTINUOUS_ERROR_LIMIT = 10
    def initialize(yaml = nil)
      @yaml = yaml
      init_config
      init_client
      init_response
      init_notifier
      prepare
    end

    def run
      loop do
        @config.room_ids.each do |room_id|
          res = @client.load_chat(room_id, @response.get(room_id).fetch('last_chat_id'))
          @response.set(room_id, res)
          if @response.success?(room_id)
            if @response.notify?(room_id)
              @notifier.notify(@response.get(room_id))
            end
            @error_count = 0
          else
            init_client
            @error_count += 1
            break
          end
        end

        sleep @interval
        break if @error_count > CONTINUOUS_ERROR_LIMIT
      end
    end

  private
    def init_config
      @config = Config.load(@yaml)
    end

    def init_client
      @client = Client.new(@config.chatwork_email, @config.chatwork_pass)
    end

    def init_response
      @response = Response.new(@config.room_ids)
    end

    def init_notifier
      @notifier = Notifier.new(@config.notifiers)
    end

    def prepare
      #@interval    = 2.minutes
      @interval    = 15.seconds
      @error_count = 0
    end
  end
end
