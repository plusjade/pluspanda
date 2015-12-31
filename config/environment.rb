# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.routes.default_url_options[:host] = 'api.pluspanda.com'
  Rails.application.routes.default_url_options[:protocol] = 'https'
Mime::Type.register "text/html", :iframe
