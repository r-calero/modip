require 'net/http'
require 'uri'
require 'json'
require 'openssl'

# Cloudflare Turnstile (captcha) verification, built on the standard library.
#
#   MODIP_CAPTCHA_SITE_KEY  public key, rendered in the forms
#   MODIP_CAPTCHA_SECRET    secret key, used to verify tokens server side
#
# Without both keys the captcha is disabled (development). When it is enabled
# and the verification cannot be done (network error, timeout), the request
# is rejected: the check fails closed.
module Turnstile
  VERIFY_URL = 'https://challenges.cloudflare.com/turnstile/v0/siteverify'
  SCRIPT_URL = 'https://challenges.cloudflare.com/turnstile/v0/api.js'
  RESPONSE_FIELD = 'cf-turnstile-response'

  def self.site_key
    ENV['MODIP_CAPTCHA_SITE_KEY'].to_s.strip
  end

  def self.secret
    ENV['MODIP_CAPTCHA_SECRET'].to_s.strip
  end

  def self.enabled?
    !site_key.empty? && !secret.empty?
  end

  # true when Cloudflare accepts the token sent by the widget.
  def self.verify(token, remote_ip = nil)
    return true unless enabled?
    return false if token.to_s.empty?

    uri = URI.parse(VERIFY_URL)
    http = new_http(uri)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Post.new(uri.request_uri)
    form = { 'secret' => secret, 'response' => token.to_s }
    form['remoteip'] = remote_ip.to_s if remote_ip
    request.set_form_data(form)

    result = JSON.parse(http.request(request).body)
    unless result['success'] == true
      log("captcha rejected: #{Array(result['error-codes']).join(', ')}")
    end
    result['success'] == true
  rescue StandardError, Timeout::Error => e
    log("captcha verification failed: #{e.class}: #{e.message}")
    false
  end

  def self.new_http(uri)
    proxy = ENV['MODIP_PROXY'].to_s
    return Net::HTTP.new(uri.host, uri.port, nil) if proxy.empty?
    p = URI.parse(proxy)
    Net::HTTP.new(uri.host, uri.port, p.host, p.port, p.user, p.password)
  end

  def self.log(message)
    Rails.logger.warn("[turnstile] #{message}") if defined?(Rails) && Rails.logger
  end
end
