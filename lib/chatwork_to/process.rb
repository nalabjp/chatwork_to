module ChatworkTo
  class Process
    CONTINUOUS_ERROR_LIMIT = 10
    def initialize(opts = {})
      @options = opts
      prepare
    end

    def run
      info('Info: ChatworkTo start.')
      loop do
        @rooms.each do |rid, data|
          @response.store(rid, @client.load_chat(rid, @response.last_chat_id(rid)))
          if @response.success?(rid)
            if @response.notify?(rid)
              notify(
                {
                  'chat_list' => @response.chat_list(rid),
                  'room' => {
                    'id' => rid,
                    'name' => data['n']
                  },
                  'users' => @all_users
                }
              )
            end
            @error_count = 0
          else
            init_client
            info('Warn: Restart client')
            @error_count += 1
            break
          end
        end

        sleep @interval
        if @error_count > CONTINUOUS_ERROR_LIMIT
          info("Error: Exit caused by #{CONTINUOUS_ERROR_LIMIT} continuous error has occurred.")
          break
        end
      end
    end

  private
    def init_config
      @config = Config.load(@options)
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

    def notify(hash)
      @notifier.notify(hash)
    end

    def info(message)
      @notifier.info(message)
    end
  end
end
