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
      notify('Info: ChatworkTo start.')
      loop do
        @config.room_ids.each do |room_id|
          @response.store(room_id, @client.load_chat(room_id, @response.last_chat_id(room_id)))
          if @response.success?(room_id)
            if @response.notify?(room_id)
              notify(@response.chat_list(room_id))
            end
            @error_count = 0
          else
            init_client
            notify('Warn: Restart client')
            @error_count += 1
            break
          end
        end

        sleep @interval
        if @error_count > CONTINUOUS_ERROR_LIMIT
          notify("Error: Exit caused by #{CONTINUOUS_ERROR_LIMIT} continuous error has occurred.")
          break
        end
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
      @interval    = 1.minutes
      @error_count = 0
    end

    def notify(notification)
      @notifier.notify(notification)
    end
  end
end
