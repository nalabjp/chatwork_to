module ChatworkTo
  class Response
    def initialize(rooms)
      @responses = {}
      rooms.each do |rid|
        @responses[rid] = default_response
      end
    end

    def store(room_id, response)
      old = @responses[room_id]

      current = default_response.merge({ 'success' => response['status']['success'] })
      if current['success']
        current['chat_list'] = response['result']['chat_list']
        if old['last_chat_id'].eql?(0)
          # init_load
          if current['chat_list'].present?
            current['last_chat_id'] = current['chat_list'].last.fetch('id')
          end
        else
          if current['chat_list'].present?
            # updated
            current['last_chat_id'] = current['chat_list'].last.fetch('id')
            current['notify'] = true
          else
            # not updated
            current['last_chat_id'] = old['last_chat_id']
          end
        end
      else
        current['error_message'] = response['status']['message']
      end

      @responses[room_id] = current
    end

    def success?(room_id)
      @responses[room_id]['success']
    end

    def notify?(room_id)
      @responses[room_id]['notify']
    end

    def last_chat_id(room_id)
      @responses[room_id]['last_chat_id']
    end

    def chat_list(room_id)
      @responses[room_id]['chat_list']
    end

  private
    def default_response
      {
        'success' => false,
        'notify'  => false,
        'last_chat_id' => 0,
      }
    end
  end
end
