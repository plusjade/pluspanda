# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.routes.default_url_options[:host] = "localhost:3000"
Rails.application.routes.default_url_options[:protocol] = "http"
Mime::Type.register "text/html", :iframe
