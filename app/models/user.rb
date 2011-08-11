require 'app/models/seed.rb'

class User < ActiveRecord::Base
  include Seed
  acts_as_authentic
  has_many :testimonials, :dependent => :destroy
  has_many :tweets, :dependent => :destroy
  has_many :widget_logs, :dependent => :destroy
  has_many :themes, :dependent => :destroy   
  has_one :tconfig, :dependent => :destroy
  has_one :tweet_setting, :dependent => :destroy
  
  validates_uniqueness_of :email
  
  before_create :generate_defaults
  after_create  :create_dependencies
  
  def generate_defaults 
    self.apikey = ActiveSupport::SecureRandom.hex(8)
  end
  
  
  def create_dependencies
    self.create_tconfig
    self.seed_testimonials
    self.themes.create(:name => 0, :staged => true)
  end


  # we always get the staged theme-attributes
  def get_attribute(attribute)
    self.theme_staged.theme_attributes.find_by_name(ThemeAttribute.names.index(attribute))
  end
  
  
  def theme_staged
    theme = self.themes.find_by_staged(true)
    unless theme
      theme = self.themes.first
      theme.staged = true
      theme.save
    end
    
    theme
  end
  
  def publish_theme
    publish_css
    publish_theme_config
  end

  def publish_css
    storage = Storage.new(self.apikey)
    storage.connect
    storage.add_stylesheet(generate_css)
  end
  
  # HTML is packaged in the theme_config
  def publish_theme_config
    storage = Storage.new(self.apikey)
    storage.connect
    storage.add_theme_config(generate_theme_config)
  end
  
  def generate_css
    css = self.get_attribute("style.css").staged
    facebox_path = Rails.root.join("public","stylesheets","facebox.css")
    if File.exist?(facebox_path)
      css << "\n" << File.new(facebox_path).read
    end
    css
  end
  
  def generate_theme_config(for_staging=false)
    Theme.render_theme_config({
      :user         => self,
      :stylesheet   => for_staging ? "" : self.stylesheet_url,
      :wrapper      => self.get_attribute("wrapper.html").staged,
      :testimonial  => self.get_attribute("testimonial.html").staged
    })    
  end

  def generate_tweet_bootstrap(for_staging=false)
    #Theme.render_tweet_bootstrap({
    #  :user         => self,
    #  :stylesheet   => for_staging ? "" : self.stylesheet_url,
    #  :wrapper      => self.get_attribute("wrapper.html").staged,
    #  :tweet        => self.get_attribute("testimonial.html").staged
    #})    
    Theme.render_tweet_bootstrap(
      :user         => self,
      :stylesheet   => "#{Theme::Themes_url}/tweets/style.css",
      :wrapper      => Theme.render_theme_attribute("tweets", "tweet-wrapper.html"),
      :tweet        => Theme.render_theme_attribute("tweets", "tweet.html")
    )
  end

  def stylesheet_url
    Storage.new(self.apikey).stylesheet_url
  end
  
  def theme_config_url
    Storage.new(self.apikey).theme_config_url
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


  def tweets_as_api
    tweets = []
    self.tweets.where(:trash => false).order("position ASC, created_at DESC").each do |t| 
      tweets.push(t.data_json)
    end
    
    tweets
  end

  def self.creation_by_month
    self.find_by_sql("
      SELECT count(id) as total_count, MONTH(created_at) as month, YEAR(`created_at`) as year
      FROM users
      GROUP BY month, year
      HAVING month IS NOT NULL 
      ORDER BY year desc, month desc
    ")
  end
  
  def self.total_by_login_count
    self.find_by_sql("
      SELECT count(id) as total, if(login_count >= 8, 8, login_count) as logins 
      FROM users
      GROUP BY logins
      ORDER BY logins
    ")
  end
  
  def self.stale
    self.find_by_sql("
      SELECT count(id) as total
      FROM users
      WHERE DATE_SUB(CURDATE(),INTERVAL 30 DAY) >= created_at
      AND login_count <= 3
    ")
  end
  
  def self.unstale
    self.find_by_sql("
      SELECT count(id) as total
      FROM users
      WHERE DATE_SUB(CURDATE(),INTERVAL 30 DAY) >= created_at
      AND login_count > 3
    ")
  end
  
end
