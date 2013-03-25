class UserMailer < ActionMailer::Base
  default :from => "info@pluspanda.com"

  # send welcome email from manually created account
  def welcome(user)
      @user = user
      mail(:to => user.email,
           :subject => "Hello from Pluspanda testimonials service =)")
  end

  def password_reset_instructions(user)
      @user = user
      @reset_link = "http://api.pluspanda.com/session/perishable?token=#{@user.perishable_token}"
      mail(:to => user.email,
           :subject => "Pluspanda pasword reset instructions.")
  end

  # notify users of a  new testimonial from public form
  def new_testimonial(user, testimonial)
    @user = user
    @testimonial = testimonial
    mail(:to => user.email,
         :subject => "You've received 1 new testimonial")    
  end 
end
