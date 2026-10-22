# Anti-bot checks for public forms (registration, password reset, login):
#   - honeypot: a field hidden with CSS that people leave empty and bots fill;
#   - timing: a signed timestamp; forms sent faster than MIN_SECONDS are bots;
#   - captcha: Cloudflare Turnstile, when it is configured.
# Include it in a controller and call `human_form_submission?`.
module FormProtection
  HONEYPOT_FIELD = 'contact_website'
  TIMESTAMP_FIELD = 'form_started'
  MIN_SECONDS = 3
  MAX_AGE = 24 * 3600

  def self.included(base)
    base.helper_method :form_protection_token if base.respond_to?(:helper_method)
  end

  # Value for the hidden TIMESTAMP_FIELD.
  def form_protection_token
    SignedToken.generate('form', { 'started' => Time.now.to_i }, MAX_AGE)
  end

  # Returns nil when the submission looks human, or a short reason otherwise.
  # timing: false skips the minimum time (login forms filled by password managers).
  def bot_submission_reason(captcha = Turnstile.enabled?, timing = true)
    return 'honeypot' unless params[HONEYPOT_FIELD].blank?
    if timing
      data = SignedToken.verify('form', params[TIMESTAMP_FIELD])
      return 'form token' unless data
      return 'too fast' if Time.now.to_i - data['started'].to_i < MIN_SECONDS
    end
    return 'captcha' if captcha && !Turnstile.verify(params[Turnstile::RESPONSE_FIELD], request.remote_ip)
    nil
  end

  def human_form_submission?(captcha = Turnstile.enabled?, timing = true)
    reason = bot_submission_reason(captcha, timing)
    logger.warn("[form protection] rejected #{controller_name}##{action_name} from #{request.remote_ip}: #{reason}") if reason
    reason.nil?
  end
end
