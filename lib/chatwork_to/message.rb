module ChatworkTo
  class Message
    class << self
      def from_string(text)
        new.instance_eval { @text = text; self }
      end

      def from_chat_list(chat_list, room)
        ret = []
        chat_list.each do |chat|
          ret << new.instance_eval do
            @msg_id    = chat['id']
            @from      = chat['aid']
            @msg       = chat['msg']
            @room_id   = room['id']
            @room_name = room['name']
            @text = "#{@room_name}(rid:#{@room_id})\n" << \
                    "[From: #{@from}]\n" << \
                    "#{@msg}"
            self
          end
        end
        ret
      end
    end

    def to_s
      @text
    end
  end
end
