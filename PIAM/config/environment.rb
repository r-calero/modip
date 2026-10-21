# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PIAM::Application.initialize!

# e-mail configuration
PIAM::Application.configure do
	config.action_mailer.delivery_method = :smtp
	
	config.action_mailer.smtp_settings = {
	    :address => ENV['MODIP_SMTP_ADDRESS'] || "smtp.gmail.com",
        :port => (ENV['MODIP_SMTP_PORT'] || 587).to_i,
        #:domain => "gmail.com",
        #:authentication => "login",
        :authentication => (ENV['MODIP_SMTP_AUTHENTICATION'] || "plain").to_sym,
        :user_name => ENV['MODIP_SMTP_USER'] || "someone@gmail.com",
        :password => ENV['MODIP_SMTP_PASSWORD'] || "secret",
        :enable_starttls_auto => ENV['MODIP_SMTP_STARTTLS'] != 'false'
	}
end

