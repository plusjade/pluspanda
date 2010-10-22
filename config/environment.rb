# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Pluspanda::Application.initialize!

sendgrid = YAML::load(File.open("#{::Rails.root.to_s}/config/sendgrid.yml"))
ActionMailer::Base.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => '25',
  :domain => "api.pluspanda.com",
  :authentication => :plain,
  :user_name => sendgrid['user_name'],
  :password => sendgrid['password']
}
ActionMailer::Base.default :content_type => "text/html"

Mime::Type.register "text/html", :iframe