require 'app/models/seed.rb'

class User < ActiveRecord::Base
  include Seed
  acts_as_authentic
  
  has_many :testimonials, :dependent => :destroy
  has_many :standard_themes, :dependent => :destroy   
  has_one :tconfig, :dependent => :destroy

  has_many :tweets, :dependent => :destroy
  has_many :tweet_themes, :dependent => :destroy   
  has_one :tweet_setting, :dependent => :destroy

  has_many :widget_logs, :dependent => :destroy
  
  validates_uniqueness_of :email
  
  before_create :generate_defaults
  after_create  :create_dependencies
  
  def generate_defaults 
    self.apikey = ActiveSupport::SecureRandom.hex(8)
  end
  
  
  def create_dependencies
    # standard testimonials
    self.create_tconfig
    self.seed_testimonials
    self.standard_themes.create(:name => 0, :staged => true)
    
    # tweet testimonials
    self.create_tweet_setting
    self.seed_tweets
    self.tweet_themes.create(:name => 0, :staged => true)
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
