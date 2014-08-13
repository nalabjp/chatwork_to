module ChatworkTo
  class Process
    CONTINUOUS_ERROR_LIMIT = 10
    def initialize(yaml = nil)
      @yaml = yaml
      prepare
    end

    def run
      notify(message_from_string('Info: ChatworkTo start.'))
      loop do
        @rooms.each do |rid, data|
          @response.store(rid, @client.load_chat(rid, @response.last_chat_id(rid)))
          if @response.success?(rid)
            if @response.notify?(rid)
              notify(message_from_chat_list(@response.chat_list(rid), {'id' => rid, 'name' => data['n']}, @all_users))
            end
            @error_count = 0
          else
            init_client
            notify(message_from_string('Warn: Restart client'))
            @error_count += 1
            break
          end
        end

        sleep @interval
        if @error_count > CONTINUOUS_ERROR_LIMIT
          notify(message_from_string("Error: Exit caused by #{CONTINUOUS_ERROR_LIMIT} continuous error has occurred."))
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
      @response = Response.new(@config.rooms)
    end

    def init_notifier
      @notifier = Notifier.new(@config.notifiers)
    end

    def prepare
      init_config
      init_client
      init_response
      init_notifier
      prepare_vars
    end

    def prepare_vars
      @interval    = 1.minutes
      @error_count = 0
      data = @client.init_load
      @all_users = data['result']['contact_dat']
      rooms = data['result']['room_dat']
      @rooms = {}
      @config.rooms.each { |id| @rooms[id] = rooms[id] }
    end

    def message_from_string(text)
      Message.from_string(text)
    end

    def message_from_chat_list(chat_list, room, all_users)
      Message.from_chat_list(chat_list, room, all_users)
    end

    def notify(messages)
      @notifier.notify(messages)
    end
  end
end
