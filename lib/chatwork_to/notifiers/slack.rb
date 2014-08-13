module ChatworkTo
  module Notifiers
    class Slack
      def initialize(opts = {})
        @debug = !!opts.delete('debug')
        build_uri(opts)
      end

      def notify(hash)
        hash['chat_list'].each do |chat|
          fid   = chat['aid'].to_s
          fname = hash['users'][fid]['name']
          rid   = hash['room']['id']
          rname = hash['room']['name'].presence || fname
          msg   = chat['msg']
          text = "#{rname}(rid:#{rid})\n" << \
                 "[From: #{fname}(id:#{fid})]\n" << \
                 "#{msg}"
          exec_notify(post_request(text))
        end
      end

      def info(message)
        exec_notify(post_request(message))
      end
    private
      def build_uri(opts)
        @uri = URI.parse("https://#{opts['subdomain']}.slack.com")
        @uri.path = '/services/hooks/incoming-webhook'
        @uri.query = "token=#{opts['token']}"
        @uri
      end

      def post_request(text)
        req = Net::HTTP::Post.new("#{@uri.path}?#{@uri.query}", initheader = {'Content-Type' => 'application/json'})
        req.body = {username: 'ChatworkTo', text: text}.to_json
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
    end
  end
end
