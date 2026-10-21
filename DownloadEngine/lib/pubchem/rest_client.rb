require 'net/http'
require 'openssl'
require 'uri'
require 'json'
require 'thread'

module PubChem
  class RestError < StandardError
    attr_reader :status, :url

    def initialize(message, status = nil, url = nil)
      super(message)
      @status = status
      @url = url
    end
  end

  # 404 from PUG REST, e.g. a compound without a 3D conformer.
  class NotFoundError < RestError; end

  # 5xx from PUG REST, e.g. 503 PUGREST.ServerBusy. These are retried.
  class ServerError < RestError; end

  # Minimal HTTP client for PubChem PUG REST, built only on the standard library.
  #
  # - Honors the proxy given to DownloadEngine ("http://user:pass@host:port").
  # - Retries network errors and 5xx answers (same 10 attempts / 1.5 s as the old SOAP client).
  # - Does not retry 4xx answers: they will not change on a retry.
  # - Keeps at most 5 requests per second per process (PubChem usage policy).
  class RestClient
    BASE_URL = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug'

    NETWORK_ERRORS = [Timeout::Error, SocketError, SystemCallError, EOFError, IOError,
                      OpenSSL::SSL::SSLError, Net::HTTPBadResponse, ServerError]

    attr_reader :proxy

    def initialize(proxy = "", options = {})
      @proxy = proxy.to_s
      @base_url = options[:base_url] || BASE_URL
      @attempts = options[:attempts] || 10
      @retry_wait = options.has_key?(:retry_wait) ? options[:retry_wait] : 1.5
      @min_interval = options.has_key?(:min_interval) ? options[:min_interval] : 0.25
      @open_timeout = options[:open_timeout] || 30
      @read_timeout = options[:read_timeout] || 180
      @verify_ssl = options.has_key?(:verify_ssl) ? options[:verify_ssl] : ENV['DOWNLOAD_ENGINE_SSL_VERIFY'] != 'false'
      @last_request_at = nil
      @lock = Mutex.new
    end

    def proxy=(other)
      @proxy = other.to_s
    end

    # Absolute URL for a PUG REST path ("compound/cid/2244/SDF").
    def url_for(path, params = nil)
      url = path =~ /\Ahttps?:\/\//i ? path.dup : "#{@base_url}/#{path.sub(/\A\//, '')}"
      if params && !params.empty?
        url << (url.include?('?') ? '&' : '?') << encode_form(params)
      end
      url
    end

    def get(path, params = nil)
      request(:get, url_for(path, params))
    end

    # Form POST. Commas inside values are sent as is: PUG REST ignores
    # a "sid" list whose commas are encoded as %2C.
    def post(path, form)
      request(:post, url_for(path), encode_form(form))
    end

    def get_json(path, params = nil)
      JSON.parse(get(path, params))
    end

    def post_json(path, form)
      JSON.parse(post(path, form))
    end

    # Downloads a URL or path into a file and returns the file path.
    def download(path, file)
      body = get(path)
      File.open(file, 'wb') { |f| f.write(body) }
      file
    end

    private

    def encode_form(form)
      form.map do |key, value|
        encoded = value.to_s.split(',', -1).map { |part| URI.encode_www_form_component(part) }.join(',')
        "#{URI.encode_www_form_component(key.to_s)}=#{encoded}"
      end.join('&')
    end

    def request(method, url, body = nil)
      attempt = 1
      begin
        throttle
        handle_response(perform(method, url, body), url)
      rescue *NETWORK_ERRORS => e
        raise e if attempt >= @attempts
        attempt += 1
        sleep @retry_wait if @retry_wait > 0
        retry
      end
    end

    def perform(method, url, body)
      uri = URI.parse(url)
      http = new_http(uri)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = @verify_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
      end
      http.open_timeout = @open_timeout
      http.read_timeout = @read_timeout

      if method == :post
        req = Net::HTTP::Post.new(uri.request_uri)
        req['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = body
      else
        req = Net::HTTP::Get.new(uri.request_uri)
      end
      req['User-Agent'] = 'DownloadEngine (MODIP)'
      http.start { |connection| connection.request(req) }
    end

    def new_http(uri)
      if @proxy.empty?
        # :ENV keeps the old behavior of using http_proxy from the environment (Ruby >= 2.0).
        env_proxy = RUBY_VERSION >= '2.0' ? :ENV : nil
        Net::HTTP.new(uri.host, uri.port, env_proxy)
      else
        p = URI.parse(@proxy)
        user = p.user ? URI.decode_www_form_component(p.user) : nil
        password = p.password ? URI.decode_www_form_component(p.password) : nil
        Net::HTTP.new(uri.host, uri.port, p.host, p.port, user, password)
      end
    end

    def handle_response(response, url)
      status = response.code.to_i
      body = response.body.to_s
      return body if status >= 200 && status < 300

      message = "PubChem REST error #{status}: #{error_detail(body)} (#{url})"
      if status == 404
        raise NotFoundError.new(message, status, url)
      elsif status >= 500
        raise ServerError.new(message, status, url)
      else
        raise RestError.new(message, status, url)
      end
    end

    # PUG REST errors come as "Code: ...\nMessage: ..." text or as a JSON Fault.
    def error_detail(body)
      fault = JSON.parse(body)['Fault'] rescue nil
      if fault
        [fault['Code'], fault['Message'], Array(fault['Details']).join(' ')].compact.join(' - ')
      else
        lines = body.lines.map { |l| l.strip }.select { |l| l =~ /\A(Code|Message|Detail):/ }
        lines.empty? ? body[0, 300].to_s.strip : lines.join(' - ')
      end
    end

    def throttle
      return if @min_interval <= 0
      @lock.synchronize do
        if @last_request_at
          wait = @min_interval - (Time.now - @last_request_at)
          sleep wait if wait > 0
        end
        @last_request_at = Time.now
      end
    end
  end
end
