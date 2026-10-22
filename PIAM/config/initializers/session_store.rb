# Be sure to restart your server when you modify this file.

# HttpOnly (not readable from JavaScript) and, with HTTPS, Secure.
PIAM::Application.config.session_store :cookie_store, :key => '_PIAM_session', :httponly => true,
                                       :secure => Rails.env.production? && ENV['MODIP_FORCE_SSL'] != 'false'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# PIAM::Application.config.session_store :active_record_store
