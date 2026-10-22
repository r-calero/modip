require 'json'
require 'active_support/message_verifier'

# Signed, expiring tokens for links sent by e-mail (account confirmation,
# password reset). They need no database table: the data travels inside the
# token, signed with a key derived from the app secret token, so it cannot be
# changed or forged. Payloads are serialized as JSON (not Marshal).
module SignedToken
  module JsonSerializer
    def self.dump(value)
      JSON.generate(value)
    end

    def self.load(value)
      JSON.parse(value)
    end
  end

  # Returns a URL-safe token for `data` (a Hash) valid for `ttl` seconds.
  def self.generate(purpose, data, ttl)
    payload = data.merge('purpose' => purpose.to_s, 'expires_at' => Time.now.to_i + ttl.to_i)
    verifier.generate(payload)
  end

  # Returns the data Hash, or nil if the token is invalid, expired or was
  # issued for another purpose.
  def self.verify(purpose, token)
    payload = verifier.verify(token.to_s)
    return nil unless payload.is_a?(Hash) && payload['purpose'] == purpose.to_s
    return nil if payload['expires_at'].to_i < Time.now.to_i
    payload
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ArgumentError, JSON::ParserError
    nil
  end

  def self.verifier
    secret = OpenSSL::HMAC.hexdigest('SHA256', Rails.application.config.secret_token, 'modip-signed-token')
    ActiveSupport::MessageVerifier.new(secret, :serializer => JsonSerializer, :digest => 'SHA256')
  end
end
