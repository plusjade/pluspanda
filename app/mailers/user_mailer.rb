class UserMailer < ActionMailer::Base
  default :from => "info@pluspanda.com"
  
  # send welcome email from manually created account
  def welcome(user)
      @user = user
      mail(:to => user.email,
           :subject => "Hello from Pluspanda testimonials service =)")
  end
   
  
  # send a welcome email from auto generated account with temp password
  def welcome_auto
    
  end
  
  # notify users of a  new testimonial from public form
  def testimonial_notify
    
  end 
   
end
