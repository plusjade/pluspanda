require 'app/models/seed.rb'

class User < ActiveRecord::Base
  include Seed
  acts_as_authentic
  has_many :testimonials, :dependent => :destroy
  has_many :widget_logs, :dependent => :destroy
  has_many :themes, :dependent => :destroy   
  has_one :tconfig, :dependent => :destroy
  
  validates_uniqueness_of :email
  
  before_create :generate_defaults
  after_create  :create_dependencies
  
  Theme_config_filename = "theme_config.js"
  Stylesheet_filename = "style.css"
  
  
  def generate_defaults 
    self.apikey = ActiveSupport::SecureRandom.hex(8)
  end
  
  
  def create_dependencies
    self.create_tconfig
    self.seed_testimonials
    #seed_theme
  end


  # we always get the staged theme-attributes
  def get_attribute(attribute)
    self.theme_staged.theme_attributes.find_by_name(ThemeAttribute.names.index(attribute))
  end
  
  
  def theme_staged
    self.themes.find_by_staged(true)
  end
  
  def publish_theme
    context = ApplicationController.new

    #matches {{blah_token}}
    token_reg = /\{{2}(\w+)\}{2}/i
        
    # item HTML
      # accessible public api testimonial attributes
      tokens = Testimonial.api_attributes
    
    #
    testimonial_html = self.get_attribute("testimonial.html").staged.gsub(/[\n\r\t]/,'')
    testimonial_html = testimonial_html.gsub(token_reg) { |tkn|
      tokens.include?($1.to_sym) ? "'+item.#{$1.to_s}+'" : tkn
    }
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
    
    wrapper_html = self.get_attribute("wrapper.html").staged.gsub(/[\n\r\t]/,'')
    wrapper_html = wrapper_html.gsub(token_reg) { |tkn|
      wrapper_tokens.has_key?($1.to_sym) ? wrapper_tokens[$1.to_sym] : tkn
    }
    puts wrapper_html    


    settings = context.render_to_string(
      :partial => "testimonials/theme_config",
      :locals   => {
        :user               => self,
        :wrapper_html       => wrapper_html,
        :testimonial_html   => testimonial_html  
      }
    )
    
    # html
    f = File.new(theme_config_path, "w+")
    f.write(settings)
    f.rewind
    
    #css
    style = self.get_attribute("style.css").staged
    f = File.new(stylesheet_path, "w+")
    f.write(style)
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

  # the published stylesheet is NOT theme specific.
  def stylesheet_url
    "system/data/#{self.apikey}/#{Stylesheet_filename}"
  end

  def stylesheet_path 
    return data_path(Stylesheet_filename)
  end
  
    
  def theme_config
    has_theme_config? ? File.open(theme_config_path).read : "#{Theme_config_filename} not found!"
  end

  def has_theme_config?
    File.exist?(theme_config_path)
  end

  def theme_config_path
    return data_path(Theme_config_filename)
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
