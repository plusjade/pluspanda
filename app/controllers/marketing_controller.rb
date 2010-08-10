class MarketingController < ApplicationController

  def index
    @meta   = 'Embedable customer testimonials and reviews for your business website.'
    @title  = 'Easily Collect, Manage, and Display Customer Testimonials On Your Website'
    @active = 'home'
  end


  def pricing
    @meta   = 'Plans and pricing for testimonial and review layouts and templates for your website'
    @title  = 'Plans and Pricing'
  end
 
  
  def faq
    @meta   = 'Pluspanda website testimonial template builder frequently asked questions'
    @title  = 'Frequenty Asked Questions '
  end


  def contact
    @meta   = 'Pluspanda website testimonials builder contact information'
    @title  = 'Contact me'
  end
 
    
  def terms_of_service
    @meta   = ''
    @title  = 'Terms of Service'  
  end
  
  
  def privacy_policy
    @meta   = ''
    @title  = 'Privacy Policy'
  end   
  
       
end
