require 'digest/sha1'

# Counts failed logins per user name and per client IP (in Rails.cache) to
# slow down password guessing:
#   - after CAPTCHA_AFTER failures from an IP, the login form asks for the captcha;
#   - after MAX_FAILURES failures for a user name (or MAX_FAILURES_PER_IP from
#     an IP), logins are refused until WINDOW has passed without new failures.
module LoginThrottle
  CAPTCHA_AFTER = 3
  MAX_FAILURES = 5
  MAX_FAILURES_PER_IP = 20
  WINDOW = 15 * 60 # seconds

  def self.locked?(name, ip)
    failures(:name, name) >= MAX_FAILURES || failures(:ip, ip) >= MAX_FAILURES_PER_IP
  end

  def self.captcha_required?(ip)
    failures(:ip, ip) >= CAPTCHA_AFTER
  end

  def self.record_failure(name, ip)
    [[:name, name], [:ip, ip]].each do |kind, value|
      Rails.cache.write(key(kind, value), failures(kind, value) + 1, :expires_in => WINDOW)
    end
  end

  def self.reset(name, ip)
    Rails.cache.delete(key(:name, name))
    Rails.cache.delete(key(:ip, ip))
  end

  def self.failures(kind, value)
    Rails.cache.read(key(kind, value)).to_i
  end

  def self.key(kind, value)
    "login-failures:#{kind}:#{Digest::SHA1.hexdigest(value.to_s.downcase)}"
  end
end
