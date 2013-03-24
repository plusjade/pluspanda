require 'sanitize'
class Testimonial < ActiveRecord::Base
  has_attached_file :avatar,
    :storage => :s3,
    :s3_credentials => Rails.root.join("config", "s3.yml"),
    :s3_permissions => :public_read,
    :bucket => Rails.env.production? ? "pluspanda" : "pluspanda_development",
    :path   => ":attachment/:id/:style.:filename",
    :url    => "/:attachment/:id/:style.:filename",
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
      :all  => ['id','class','title','rel','style'],
      'a'   => ['href'],
      'img' => ['src','alt']
    }
  }  
    
    
  def generate_defaults 
    self.token = SecureRandom.hex(6)
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
    self.avatar.instance_write(:file_name, "#{SecureRandom.hex(4)}#{ext}")
  end
  
  def image_source
    if self.avatar_file_name.nil? || self.avatar_file_name.empty?
      self.image_stock
    else
      self.avatar.url(:sm) 
    end
  end

  def self.api_attributes
    testimonial = [
      :id,
      :rating,
      :company,
      :name,
      :location,
      :created_at,
      :body,
      :url,
      :c_position,
      :image,
      :image_stock      
    ]    
  end
  
  
  def sanitize_for_api
    testimonial = {}
  
    Testimonial.api_attributes.each do |a|
      case a
      when :image
        testimonial[a] = self.avatar? ? self.avatar.url(:sm) : false
      when :image_stock
        testimonial[a] = image_stock
      when :tag_name
        # send the name from the id obviously.
        testimonial[a] = self.tag_id
      else
        testimonial[a] = self.send a
      end
    end
    
    testimonial   
  end
  
  def image_stock
     Rails.env.production? ? "http://s3.amazonaws.com/pluspanda/stock.png" : "/images/stock.png"
  end
  
end
