# Key used to sign the session cookie. Anyone who knows it can forge sessions
# (and, with the Rails 3.2 cookie store, run code), so it must never be in the
# repository: set MODIP_SECRET_TOKEN (e.g. `openssl rand -hex 64`).
token = ENV['MODIP_SECRET_TOKEN'].to_s
if token.length < 30
  if Rails.env.production?
    raise "MODIP_SECRET_TOKEN must be set to a random value of at least 30 characters"
  end
  # Development/test only: a new key per start (sessions do not survive restarts).
  require 'securerandom'
  token = SecureRandom.hex(64)
end
PIAM::Application.config.secret_token = token
