# Rails 3.2.8 is affected by CVE-2013-0156: XML request parameters may carry
# YAML and Symbol values, which allows remote code execution. MODIP does not
# accept XML requests, so XML parameter parsing is turned off, and YAML/Symbol
# conversion is removed in case XML is parsed elsewhere. This is the official
# workaround published with the advisory (fixed in Rails 3.2.11).
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
ActiveSupport::XmlMini::PARSING.delete("symbol")
ActiveSupport::XmlMini::PARSING.delete("yaml")

# Security helpers in lib/ (not autoloaded in Rails 3.2).
require Rails.root.join('lib', 'signed_token').to_s
require Rails.root.join('lib', 'turnstile').to_s
require Rails.root.join('lib', 'login_throttle').to_s
require Rails.root.join('lib', 'form_protection').to_s

unless Turnstile.enabled?
  Rails.logger.warn("[security] MODIP_CAPTCHA_SITE_KEY/MODIP_CAPTCHA_SECRET are not set: the captcha is disabled")
end
