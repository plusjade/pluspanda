class DevMailInterceptor
  def self.delivering_email(message)
    puts "Intercepted Mail Output"
    puts message.inspect
    puts message.body
    
    message.subject = "#{message.to} #{message.subject}"
    message.to = "plusjade@gmail.com"
  end
end

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

# we need this here because we have many non-production environments.
unless Rails.env.production?
  ActionMailer::Base.register_interceptor(DevMailInterceptor)
end