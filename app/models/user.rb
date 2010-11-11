class User < ActiveRecord::Base
  acts_as_authentic
  has_many :testimonials, :dependent => :destroy
  has_many :widget_logs, :dependent => :destroy
  has_one :tconfig, :dependent => :destroy
  
  validates_uniqueness_of :email
  
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
  end


  def settings
    return 'error! no settings file!' unless has_settings?
    return File.open(settings_file_path).read
  end
  
  
  def theme_css
    if File.exists?(theme_css_path)
      return File.open(theme_css_path).read
    else
      return '/* Your css file does not exist! */'
    end
  end 
  

  def theme_stock_css
    if File.exists?(theme_stock_css_path)
      return File.open(theme_stock_css_path).read  
    else
      return "/* no available css for theme: #{self.tconfig.theme}*/"
    end
  end
  
      
  def update_settings
    context = ApplicationController.new
    if !File.exists?(theme_css_path) && File.exists?(theme_stock_css_path)
      FileUtils.cp(theme_stock_css_path, theme_css_path)
    end
      
    tag_list          = context.render_to_string(
                          :template => "testimonials/tag_list",
                          :layout   => false,
                          :locals   => { :tags => Tag.where({:user_id => self.id }) }
                        ).gsub!(/[\n\r\t]/,'')
    panda_structure   = context.render_to_string(
                          :template => "testimonials/themes/#{self.tconfig.theme}/wrapper",
                          :layout   => false,
                          :locals   => { :tag_list => tag_list }
                        ).gsub!(/[\n\r\t]/,'')
    item_html         = context.render_to_string(
                          :template => "testimonials/themes/#{self.tconfig.theme}/item",
                          :layout => false
                          ).gsub!(/[\n\r\t]/,'')    
    settings          = context.render_to_string(
                          :template => "testimonials/widget_settings",
                          :layout   => false,
                          :locals   => {
                            :user             => self,
                            :panda_structure  => panda_structure,
                            :item_html        => item_html  
                          }
                        )
    
    f = File.new(settings_file_path, "w+")
    f.write(settings)
    f.rewind
  end
  
    
  def update_css(content)
    File.new(theme_css_path, "w+").write(content)
  end
  

  def has_settings?
    File.exist?(settings_file_path)
  end

    
  # get the testimonials
  # based on defined filters, sorters, and limits.
  # filters: page, publish, tag, rating, date.
  # sorters: created
  def get_testimonials(opts={})
    where  = {}
    opts[:get_count]  ||= false
    opts[:publish]    ||= 'yes'
    opts[:rating]     ||= ''
    opts[:range]      ||= ''
    opts[:sort]       ||= self.tconfig.sort
    opts[:updated]    ||= ''
    opts[:limit]      ||= self.tconfig.per_page
    opts[:tag]        ||= 'all'

    # filter by publish
    where[:publish] = ('yes' == opts[:publish]) ? true : false

    return self.testimonials.where(where).count if opts[:get_count]
    
    # filter by tag
    unless opts[:tag] == 'all'
      where[:tag_id] = opts[:tag].to_i
    end
      
    # filter by rating
    #if(is_numeric($params['rating']))
    #  where['rating'] = $params['rating'];
  
    #--sorters--
    sort = "created_at DESC"
    case(opts[:sort])
      when 'created'
        case(opts[:created])
          when 'newest'
            sort = "created_at DESC"
          when 'oldest'
            sort = "created_at ASC"
        end
      when 'name'
        sort = "name ASC"
      when 'company'
        sort = "company ASC"
      when 'position'
        sort = "position ASC"
     end 
     
    # determine the offset and limits.
    offset = (opts[:page]*opts[:limit]) - opts[:limit]

    return self.testimonials.where(where).order(sort).limit(opts[:limit]).offset(offset)
   end
   
   
# path helpers
################

  def settings_file_path
    return data_path('settings.js')
  end 

  
  def theme_css_path 
    return data_path("#{self.tconfig.theme}.css")
  end


  def theme_stock_css_path 
    return Rails.root.join('app','views','testimonials','themes',self.tconfig.theme, "#{self.tconfig.theme}.css")
  end  

  
  def data_path(path=nil)
    return (path.nil?) ? File.join(ensure_path) : File.join(ensure_path, path)
  end
   
      
  def ensure_path
    path = Rails.root.join('public','system', 'data', self.apikey)
    FileUtils.mkdir_p(path) if !File.directory?(path)
    return path
  end
  
    
end
