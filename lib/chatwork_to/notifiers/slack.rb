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
          attachment = {}
          attachment[:fields] = [
            {
              title: "#{rname}(rid:#{rid}) [From: #{fname}(id:#{fid})]",
              value: decorate(msg),
              short: false,
            }
          ]
          exec_notify(post_request(attachment: attachment))
        end
      end

      def info(message)
        exec_notify(post_request(text: decorate(message)))
      end
    private
      def build_uri(opts)
        @uri = URI.parse("https://#{opts['subdomain']}.slack.com")
        @uri.path = '/services/hooks/incoming-webhook'
        @uri.query = "token=#{opts['token']}"
        @uri
      end

      def post_request(hash)
        req = Net::HTTP::Post.new("#{@uri.path}?#{@uri.query}", initheader = {'Content-Type' => 'application/json'})
        req.body = {username: 'ChatworkTo', text: hash[:text], attachments: [hash[:attachment]]}.to_json
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
        auto_link_url(text)
      end

      def auto_link_url(text)
        text.gsub(/(#{URI.regexp(%w(http https))})/) do
          %w(http:// https://).include?($1) ? $1 : "<#{CGI.escape_html $1}>"
        end
      end
    end
  end
end
