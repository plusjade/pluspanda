# == Schema Information
#
# Table name: testimonials
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  tag_id           :integer
#  token            :string(255)
#  name             :string(255)
#  company          :string(255)
#  c_position       :string(255)
#  location         :string(255)
#  url              :string(255)
#  body             :text
#  body_edit        :text
#  rating           :integer
#  publish          :boolean          default(FALSE)
#  position         :integer
#  lock             :boolean          default(FALSE)
#  email            :string(255)
#  meta             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  avatar_file_name :string(255)      default(""), not null
#  trash            :boolean          default(FALSE)
#

require 'sanitize'
class Testimonial < ActiveRecord::Base

  TrialLimit = 10

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

  # get the testimonials
  # based on defined filters, sorters, and limits.
  # filters: page, publish, tag, rating, date.
  # sorters: created
  def self.from_user(opts={})
    criteria  = { 
      trash: false,
      user_id: opts[:user_id]
    }
    opts[:get_count]  ||= false
    opts[:publish]    ||= 'yes'
    opts[:rating]     ||= ''
    opts[:range]      ||= ''
    opts[:updated]    ||= ''
    opts[:tag]        ||= 'all'

    # filter by publish
    criteria[:publish] = ('yes' == opts[:publish]) ? true : false

    return where(criteria).count if opts[:get_count]
    
    # filter by tag
    unless opts[:tag] == 'all'
      criteria[:tag_id] = opts[:tag].to_i
    end

    sort = get_mysql_sort(opts[:sort], opts[:created])

    # determine the offset and limits.
    offset = (opts[:page]*opts[:limit]) - opts[:limit]

    if !opts[:premium] && ((offset + opts[:limit]) > Testimonial::TrialLimit)
      opts[:limit] = Testimonial::TrialLimit - offset
      if opts[:limit] < 0; opts[:limit] = 0; end
    end

    where(criteria)
      .order(sort)
      .limit(opts[:limit])
      .offset(offset)
  end

  def self.update_data_payload(opts)
    total = from_user({ user_id: opts[:user_id], get_count: true })
    update_data = {
      "total"   => total,
      "average" => opts[:average],
    }

    offset = ( opts[:page]*opts[:limit] ) - opts[:limit]
    chunk = offset + opts[:limit]
    if (total > chunk) && ( opts[:premium] || (TrialLimit > chunk) )
      update_data["nextPageUrl"]  = Rails.application.routes.url_helpers.testimonials_url({
                                      format: 'js',
                                      apikey: opts[:apikey],
                                      tag: opts[:tag],
                                      sort: opts[:sort],
                                      page: (opts[:page] + 1),
                                    })
      update_data["nextPage"]     = opts[:page] + 1
      update_data["tag"]          = opts[:tag]
      update_data["sort"]         = opts[:sort]
    end

    update_data
  end

  def self.get_mysql_sort(condition, created=nil)
    sort = "created_at DESC"
    case(condition)
      when 'created'
        case(created)
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

     sort
  end

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
    if self.avatar_file_name.nil? || self.avatar_file_name.blank?
      self.image_stock
    else
      self.avatar.url(:sm) 
    end
  end

  def self.api_attributes
    [
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
