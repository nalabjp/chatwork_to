module ChatworkTo
  module Notifiers
    class Slack
      def initialize(opts = {})
        @debug = !!opts.delete('debug')
        build_uri
        build_default_query(opts)
      end

      def notify(hash)
        hash['chat_list'].each do |chat|
          text, attachment = request_body(chat, hash['room'], hash['users'])
          exec_notify(post_request(text: text, attachment: attachment))
        end
      end

      def info(message)
        exec_notify(post_request(text: decorate(message)))
      end

    private
      def build_uri
        @uri = URI.parse('https://slack.com/api/chat.postMessage')
      end

      def build_default_query(opts)
        @default_query = {username: 'ChatworkTo', token: opts['token'], channel: opts['channel'], parse: 'full'}
      end

      def request_body(chat, room, users)
        fid   = chat['aid'].to_s
        fname = users[fid]['name']
        rid   = room['id']
        rname = room['name'].presence || fname
        msg   = chat['msg']
        text  = "Message from #{fname} (id:#{fid})"
        attachment = {}
        attachment[:fields] = [
          {
            fallback: 'chatwork message',
            title: "#{rname} (rid:#{rid})",
            value: decorate(msg),
            short: false,
          }
        ]
        [text, attachment]
      end

      def post_request(hash)
        req = Net::HTTP::Post.new(@uri.path)
        req.body = @default_query.merge({text: hash[:text], attachments: [hash[:attachment]].to_json}).to_query
        req
      end

      def exec_notify(req)
        https = Net::HTTP.new(@uri.hostname, @uri.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https.set_debug_output($stdout) if @debug
        res = https.start { |h| h.request(req) }
        $stdout.puts(res.body) if @debug
      end

      def decorate(text)
        text
      end
    end
  end
end
