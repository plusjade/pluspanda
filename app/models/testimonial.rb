require 'sanitize'
class Testimonial < ActiveRecord::Base

  has_one :tag
  
  before_create :generate_defaults
  before_save :sanitize

  SANITIZE_CONFIG  = {
    :elements => [
      'div','span','br','h1','h2','h3','h4','h5','h6','p','blockquote','pre','a','abbr','acronym','address','big','cite','code','del','dfn','em','font','img','ins','kbd','q','s','samp','small','strike','strong','sub','sup','tt','var','b','u','i','center','dl','dt','dd','ol','ul','li','table','caption','tbody','tfoot','thead','tr','th','td'
    ],
    :attributes => {
      :all  => ['id','class', 'title','rel','style'],
      'a'   => ['href'],
      'img' => ['src','alt']
    }
  }  
    
  def generate_defaults 
    self.token = ActiveSupport::SecureRandom.hex(6)
  end
  
  def sanitize
    self.body       = Sanitize.clean(self.body, SANITIZE_CONFIG) 
    self.company    = Sanitize.clean(self.company)
    self.c_position = Sanitize.clean(self.c_position)
    self.location   = Sanitize.clean(self.location)
    self.url        = Sanitize.clean(self.url)
    #self.url gsub!('http://','', strtolower($this->url));
  end
  
    
end
