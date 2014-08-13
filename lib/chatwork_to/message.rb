module ChatworkTo
  class Message
    class << self
      def from_string(text)
        new.instance_eval { @text = text; self }
      end

      def from_chat_list(chat_list, room, all_users)
        ret = []
        chat_list.each do |chat|
          ret << new.instance_eval do
            @msg_id    = chat['id'].to_s
            @from_id   = chat['aid'].to_s
            @from_name = all_users[@from_id]['name']
            @msg       = chat['msg']
            @room_id   = room['id']
            @room_name = room['name'].presence || @from_name
            @text = "#{@room_name}(rid:#{@room_id})\n" << \
                    "[From: #{@from_name}(id:#{@from_id})]\n" << \
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
