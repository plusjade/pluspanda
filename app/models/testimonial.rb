require 'sanitize'
class Testimonial < ActiveRecord::Base
  has_attached_file :avatar,
    :path   => ":rails_root/public/system/:attachment/:id/:style.:filename",
    :url    => "/system/:attachment/:id/:style.:filename",
    :styles => { :sm => "125x125#" }

  after_post_process :randomize_filename
  belongs_to :user
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
    self.body       = Sanitize.clean(self.body.to_s, SANITIZE_CONFIG)
    self.company    = Sanitize.clean(self.company.to_s)
    self.c_position = Sanitize.clean(self.c_position.to_s)
    self.location   = Sanitize.clean(self.location.to_s)
    self.url        = Sanitize.clean(self.url.to_s)
    #self.url gsub!('http://','', strtolower($this->url));
  end
  

  def randomize_filename
    ext = File.extname(self.avatar_file_name).downcase
    self.avatar.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(4)}#{ext}")
  end
  

  def sanitize_for_api
    testimonial = {
      :id               => self.id,
      :rating           => self.rating,
      :company          => self.company,
      :position         => self.position,
      :name             => self.name,
      :location         => self.location,
      :created_at       => self.created_at,
      :image_src        => self.avatar? ? absolute_url + self.avatar.url(:sm) : false,
      :image_stock      => image_stock,
      :tag_id           => self.tag_id,
      :body             => self.body,
      :url              => self.url,
      :c_position       => self.c_position
    }
    testimonial   
  end
  
  
  def absolute_url
    ::Rails.env == 'production' ? 'http://api.pluspanda.com' : 'http://localhost:3000'
  end
    
  
  def image_stock
     absolute_url + '/images/stock.png'
  end
  
end
