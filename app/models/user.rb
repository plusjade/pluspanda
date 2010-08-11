class User < ActiveRecord::Base
  acts_as_authentic
  has_one :tconfig
  
  before_create :generate_defaults
  after_create  :create_dependencies
  
  def generate_defaults 
    self.apikey = ActiveSupport::SecureRandom.hex(8)
  end
  
  def create_dependencies
    @tconfig = self.build_tconfig
    @tconfig.save    
    
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
    src = Rails.root.join('public','stylesheets', 'testimonials', 'stock')
    FileUtils.cp_r(src, File.join(data_path, 'css'))
  end


  # return path to user data directory
  def data_path(path=nil)
    return (path.nil?) ? File.join(ensure_path) : File.join(ensure_path, path)
  end
      
  def ensure_path
    path = Rails.root.join('public','system', 'data', self.apikey)
    FileUtils.mkdir_p(path) if !File.directory?(path)
    return path
  end
  
    
end
