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
  
  def image_source
    if self.avatar_file_name.nil? || self.avatar_file_name.empty?
      "/images/stock.png"
    else
      self.avatar.url(:sm) 
    end
  end

  def self.api_attributes
    testimonial = [
      :id,
      :rating,
      :company,
      :position,
      :name,
      :location,
      :created_at,
      :tag_id,
      :body,
      :url,
      :c_position,
      :image_src,
      :image_stock      
    ]    
  end
  
  
  def sanitize_for_api
    testimonial = {}
  
    Testimonial.api_attributes.each do |a|
      if a == :image_src
        testimonial[a] = self.avatar? ? root_url + self.avatar.url(:sm) : false
      elsif a == :image_stock
        testimonial[a] = image_stock
      else
        testimonial[a] = self.send a
      end
    end
    
    testimonial   
  end
  
  
  def root_url
    ::Rails.env == 'production' ? 'http://api.pluspanda.com' : 'http://localhost:3000'
  end
    
  
  def image_stock
     root_url + '/images/stock.png'
  end
  
end
