module ChatworkTo
  module Notifiers
    class Slack
      def initialize(opts = {})
        @debug = !!opts.delete('debug')
        build_uri(opts)
      end

      def notify(notification)
        https = Net::HTTP.new(@uri.hostname, @uri.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https.set_debug_output($stdout) if @debug
        res = https.start { |h| h.request(request(notification)) }
        $stdout.puts(res.body) if @debug
      end

    private
      def build_uri(opts)
        @uri = URI.parse("https://#{opts['domain']}.slack.com")
        @uri.path = '/services/hooks/incoming-webhook'
        @uri.query = "token=#{opts['token']}"
        @uri
      end

      def request(notification)
        req = Net::HTTP::Post.new("#{@uri.path}?#{@uri.query}", initheader = {'Content-Type' => 'application/json'})
        req.body = {username: 'ChatworkTo', text: notification}.to_json
        req
      end
    end
  end
end
