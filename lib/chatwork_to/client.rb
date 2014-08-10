module ChatworkTo
  class Client
    CHATWORK_URL = 'https://www.chatwork.com'
    CHATWORK_ALL_JA = 'chatwork_all_ja.min.js'
    CONSTANTS_REGEXP = {
      myid: /var myid( *)=( *)'(.*)'/,
      ln:   /var LANGUAGE( *)=( *)'(.*)'/,
      _t:   /var ACCESS_TOKEN( *)=( *)'(.*)'/,
      _v:   /var client_ver( *)=( *)'(.*)'/,
    }.freeze

    def initialize(email, pass)
      @config = {}
      @chatwork_email = email
      @chatwork_pass  = pass
      @mechanize     = ::Mechanize.new
      prepare
    end

    def load_chat(room_id, last_chat_id)
      JSON.parse(@mechanize.get(build_load_chat_url(room_id, last_chat_id)).body)
    end

  private
    def prepare
      login
      parse_script_tag
      raise NotEnoughParameterError, 'Parameter is not enough' unless verify?
    end

    def login
      @mechanize.get(CHATWORK_URL)
      @mechanize.page.form_with(name: 'login') do |form|
        form.field_with(name: 'email').value = @chatwork_email
        form.field_with(name: 'password').value = @chatwork_pass
        form.click_button
      end
    end

    def parse_script_tag
      find_const  = false
      find_js_file = false
      @mechanize.page.search('script').each do |element|
        if element.children.present?
          unless find_const
            CONSTANTS_REGEXP.each do |key, regexp|
              element.inner_text =~ regexp
              break if $&.nil?
              @config[key] = $3
              find_const = true
            end
          end
        else
          unless find_js_file
            chatwork_all_ja_path = element.values.find { |item| item.include?(CHATWORK_ALL_JA) }
            if chatwork_all_ja_path.present?
              Net::HTTP.get(URI.parse("#{CHATWORK_URL}/#{chatwork_all_ja_path.sub(/^(\.?)\//, '')}")) =~ /a.api_version=(\d);/
              if $&.present?
                @config[:_av] = $1
                find_js_file = true
              end
            end
          end
        end
        break if find_const && find_js_file
      end
    end

    def verify?
      %I( myid ln _t _v _av ).all? { |item| @config[item].present? }
    end

    def build_load_chat_url(room_id, last_chat_id)
      uri = URI.parse(CHATWORK_URL)
      uri.path = '/gateway.php'
      uri.query = {
        cmd: 'load_chat',
        room_id: room_id,
        last_chat_id: last_chat_id,
      }.merge(@config).to_query
      uri.to_s
    end
  end

  class NotEnoughParameterError < StandardError; end;
end
