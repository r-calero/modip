# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PIAM::Application.initialize!

# e-mail configuration
PIAM::Application.configure do
	config.action_mailer.delivery_method = :smtp
	
	config.action_mailer.smtp_settings = {
	  :address => "10.4.1.4",
	  :port => 143
	}
end

