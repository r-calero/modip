# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PIAM::Application.initialize!

# e-mail configuration
PIAM::Application.configure do
	config.action_mailer.delivery_method = :smtp
	
	config.action_mailer.smtp_settings = {
	    :address => "smtp.gmail.com",
        :port => 587,
        #:domain => "gmail.com",
        #:authentication => "login",
        :authentication => "plain",
        :user_name => "someone@gmail.com",
        :password => "secret",
        :enable_starttls_auto => true
	}
end

