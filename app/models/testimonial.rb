class Testimonial < ActiveRecord::Base

  has_one :tag
  
  before_create :generate_defaults
  
  def generate_defaults 
    self.token = ActiveSupport::SecureRandom.hex(6)
  end
  
  def blah
    #self.url gsub!('http://','', strtolower($this->url));
    
  end
  
    
end
