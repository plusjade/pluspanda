class User < ActiveRecord::Base
  acts_as_authentic
  has_one :tconfig
  
  before_create :generate_defaults
  after_create  :create_dependencies
  
  def generate_defaults 
    self.apikey = ActiveSupport::SecureRandom.hex(8)
  end
  
  def create_dependencies
     # auto create a new tconfig.
    @tconfig = self.build_tconfig
    @tconfig.save    
    
    # add 3 sample testimonials to get the party started.
    @testimonial = Testimonial.new
    @testimonial.user_id    = self.id
    @testimonial.name       = 'Stephanie Lo'
    @testimonial.company    = 'World United'
    @testimonial.c_position = 'Founder'
    @testimonial.url        = 'worldunited.com'
    @testimonial.location   = 'Berkeley, CA'
    @testimonial.rating     = 5
    @testimonial.body       = 'The interface is simple and directed. I have a super busy schedule and did not want to waste any time learning yet another website. Pluspanda values my time. Thanks!' 
    @testimonial.publish    = 1
    @testimonial.save
      
    @testimonial = Testimonial.new
    @testimonial.user_id    = self.id
    @testimonial.name       = 'John Doe'
    @testimonial.company    = 'Super Company!'
    @testimonial.c_position = 'President'
    @testimonial.url        = 'supercompany.com'
    @testimonial.location   = 'Atlanta, Georgia'
    @testimonial.rating     = 5
    @testimonial.body       = 'This is a sample testimonial for all to see.'  
    @testimonial.publish    = 1
    @testimonial.save
    
    @testimonial = Testimonial.new
    @testimonial.user_id    = self.id
    @testimonial.name       = 'Jane Smith'
    @testimonial.company    = 'Widgets R Us'
    @testimonial.c_position = 'Sales Manager'
    @testimonial.url        = 'widgetsrus.com'
    @testimonial.location   = 'Los Angeles, CA'
    @testimonial.rating     = 5
    @testimonial.body       = 'Pluspanda makes our testimonials look great! Our widget sales our up 200% Thanks Pluspanda!'  
    @testimonial.publish    = 1
    @testimonial.save
      
      # copy stock testimonial css to user data folder
      #$src  = DOCROOT .'static/css/testimonials/stock'
      #$dest = t_paths::css($this.apikey)
      #dir::copy($src, $dest)    
  end
  
  
end
