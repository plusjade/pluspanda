class User < ActiveRecord::Base
  acts_as_authentic
  has_many :testimonials, :dependent => :destroy
  has_many :widget_logs, :dependent => :destroy
  has_many :themes, :dependent => :destroy   
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


  def get_staged_attribute(attribute)
    self.theme_staged.theme_attributes.find_by_name(ThemeAttribute.names.index(attribute))
  end
  
  
  def theme_staged
    self.themes.find_by_staged(true)
  end

  def theme_published
    self.themes.find_by_published(true)
  end
  
  
  
  
  
  def settings
    return 'error! no settings file!' unless has_settings?
    return File.open(settings_file_path).read
  end
  
  def has_settings?
    File.exist?(settings_file_path)
  end
  
  

 
      
  def update_settings
    context = ApplicationController.new
    if !File.exists?(theme_css_path) && File.exists?(theme_stock_css_path)
      FileUtils.cp(theme_stock_css_path, theme_css_path)
    end
    
    theme_path = Rails.root.join("public/themes/#{self.tconfig.theme}")
    #matches {{blah_token}}
    token_reg = /\{{2}(\w+)\}{2}/i
        
    # item HTML
      # accessible public api testimonial attributes
      tokens = Testimonial.api_attributes
    
    testimonial = "#{theme_path}/testimonial.html"
    testimonial_html = ""
    if File.exist?(testimonial)
      testimonial_html = File.open(testimonial, "r").read.gsub(/[\n\r\t]/,'')
      testimonial_html = testimonial_html.gsub(token_reg) { |tkn|
        tokens.include?($1.to_sym) ? "'+item.#{$1.to_s}+'" : tkn
      }
    end
    puts testimonial_html
    
    tag_list = context.render_to_string(
      :partial  => "testimonials/tag_list",
      :locals   => { :tags => Tag.where({:user_id => self.id }) }
    ).gsub(/[\n\r\t]/,'')    
    
    
    # Main wrapper structure
      #wrapper tokens
      wrapper_tokens = {
        :tag_list       => tag_list,
        :count          => "||COUNTER||",
        :testimonials   => "||TESTIMONIALS||",
        :add_link       => "||FORM LINK||"
      }
    
    wrapper = "#{theme_path}/wrapper.html"
    wrapper_html = ""
    if File.exist?(wrapper)
      wrapper_html = File.open(wrapper, "r").read.gsub(/[\n\r\t]/,'')
      wrapper_html = wrapper_html.gsub(token_reg) { |tkn|
        wrapper_tokens.has_key?($1.to_sym) ? wrapper_tokens[$1.to_sym] : tkn
      }
    end
    puts wrapper_html    


    settings = context.render_to_string(
      :template => "testimonials/widget_settings",
      :layout   => false,
      :locals   => {
        :user               => self,
        :wrapper_html       => wrapper_html,
        :testimonial_html   => testimonial_html  
      }
    )
    
    f = File.new(settings_file_path, "w+")
    f.write(settings)
    f.rewind
  end
  


    
  # get the testimonials
  # based on defined filters, sorters, and limits.
  # filters: page, publish, tag, rating, date.
  # sorters: created
  def get_testimonials(opts={})
    where  = {:trash => false}
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

  # the current theme's staging css
  def theme_css_path 
    return data_path("#{self.tconfig.theme}.css")
  end

  # the published css. This is NOT theme specific.
  def publish_css_path 
    return data_path("publish.css")
  end
  
  # the current theme's stock css
  def theme_stock_css_path 
    return Rails.root.join('public','themes',self.tconfig.theme, "#{self.tconfig.theme}.css")
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
