# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  email               :string(255)      not null
#  crypted_password    :string(255)      not null
#  password_salt       :string(255)      not null
#  persistence_token   :string(255)      not null
#  single_access_token :string(255)      not null
#  apikey              :string(255)      not null
#  login_count         :integer          default(0), not null
#  last_login_at       :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  perishable_token    :string(255)      not null
#  premium             :boolean          default(FALSE), not null
#

module Seed
  def seed_testimonials
    self.testimonials.create(
      :name         => "Stephanie Lo",
      :company      => "World United",
      :c_position   => "Founder",
      :url          => "worldunited.com",
      :location     => "Berkeley, CA",
      :body         => 5,
      :body         => "The interface is simple and directed. I have a super busy schedule and did not want to waste any time learning yet another website. Pluspanda values my time. Thanks!",
      :publish      => 1
    ) 

    self.testimonials.create(
      :name         => "John Doe",
      :company      => "Super Company!",
      :c_position   => "President",
      :url          => "supercompany.com",
      :location     => "Atlanta, Georgia",
      :body         => 5,
      :body         => "The interface is simple and directed. I have a super busy schedule and did not want to waste any time learning yet another website. Pluspanda values my time. Thanks!",
      :publish      => 1
    )
    
    self.testimonials.create(
      :name         => "Jane Smith",
      :company      => "Widgets R Us",
      :c_position   => "Sales Manager",
      :url          => "widgetsrus.com",
      :location     => "Los Angeles, CA",
      :body         => 5,
      :body         => "Pluspanda makes our testimonials look great! Our widget sales our up 200% Thanks Pluspanda!",
      :publish      => 1
    )
  end
end

class User < ActiveRecord::Base
  include Seed
  acts_as_authentic
  
  has_many :testimonials, :dependent => :destroy
  has_many :standard_themes, :dependent => :destroy   
  has_one :tconfig, :dependent => :destroy

  has_many :widget_logs, :dependent => :destroy
  
  validates_uniqueness_of :email
  
  before_create :generate_defaults
  after_create  :create_dependencies
  
  def generate_defaults 
    self.apikey = SecureRandom.hex(8)
  end
  
  
  def create_dependencies
    # standard testimonials
    self.create_tconfig
    self.seed_testimonials
    self.standard_themes.create(:name => 0, :staged => true).publish
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!  
    UserMailer.password_reset_instructions(self.reload).deliver
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

    if !premium && ((offset + opts[:limit]) > Testimonial::TrialLimit)
      opts[:limit] = Testimonial::TrialLimit - offset
      if opts[:limit] < 0; opts[:limit] = 0; end
    end

    testimonials.where(where).order(sort).limit(opts[:limit]).offset(offset)
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
