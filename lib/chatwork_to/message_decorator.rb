module ChatworkTo
  module MessageDecorator
    refine String do
      def gsub_quote!
        gsub!(/\[qt\]\[qtmeta.*\](.+)\[\/qt\]/) { "> #{$1.gsub(/\n/, '\n> ')}" } || self
      end

      def gsub_reply!
        gsub!(/\[rp aid=(.+) to=.+\]/) { "[Re:#{$1}]" } || self
      end

      def gsub_task_added!
        gsub!(/\[info\]\[title\]\[dtext:task_added\].+\[\/info\]/, 'Added task') || self
      end

      def gsub_task_done!
        gsub!(/\[info\]\[title\]\[dtext:task_done\].+\[\/info\]/, 'Done task') || self
      end

      def gsub_file_uploaded!
        gsub!(/\[info\].*\[download:(.+)\](.+)\[\/download\]\[\/info\]/) do
          "#{$2}\nhttps://www.chatwork.com/gateway.php?cmd=download_file&bin=1&file_id=#{$1}"
        end || self
      end

      def room_url
        "https://www.chatwork.com/#!rid#{self}"
      end
    end
  end
end
