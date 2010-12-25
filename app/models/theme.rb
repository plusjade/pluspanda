class Theme < ActiveRecord::Base

  belongs_to :user
  has_many :theme_attributes, :dependent => :destroy
  after_create :populate_attributes

  # matches {{blah_token}}
  Token_regex = /\{{2}(\w+)\}{2}/i
  Themes_path = Rails.root.join("public/themes")
  Themes_url  = "themes"

  def self.names
    [
      "list",
      "simple",
      "legacy",
      "custom"
    ]
  end
  
      
  # here we populate the associated attributes.
  # we get these from the associated theme dir. 
  # note the data should already be verified and sanitized.
  def populate_attributes
    attributes = ThemeAttribute.names
    theme_path = File.join(Themes_path, Theme.names[self.name])
    
    if File.exist?(theme_path)
      Dir.new(theme_path).each do |file|
        next if file.index('.') == 0
        if attributes.include?(file)
          contents =  File.new(File.join(theme_path, file)).read
          self.theme_attributes.create(
            :name     => attributes.index(file), 
            :staged   => contents,
            :original => contents
          )
        end
      end
    end
    
  end
  
  
  def self.render_theme_attribute(theme, attribute)
    attributes = ThemeAttribute.names
    path = File.join(Themes_path, theme, attribute)

    if attributes.include?(attribute) && File.exist?(path)
      File.new(path).read
    end

  end
  
  def self.parse_testimonial(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) { |tkn|
      tokens.include?($1.to_sym) ? "'+item.#{$1.to_s}+'" : tkn
    }
  end
  
  def self.parse_wrapper(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) { |tkn|
      tokens.has_key?($1.to_sym) ? tokens[$1.to_sym] : tkn
    }
  end
  
  def self.render_theme_config(opts)
    context = ApplicationController.new
    opts[:user]         ||= nil
    opts[:stylesheet]   ||= ""
    opts[:wrapper]      ||= ""
    opts[:testimonial]  ||= ""
    
    puts opts.to_yaml
    # parse wrapper.html
    tag_list = context.render_to_string(
      :partial  => "testimonials/tag_list",
      :locals   => { :tags => Tag.where({:user_id => opts[:user].id }) }
    ).gsub(/[\n\r\t]/,'')    
    wrapper_tokens = {
      :tag_list       => tag_list,
      :count          => '<span class="pandA-tCount_ness"></span>',
      :testimonials   => '<span class="pandA-tWrapper_ness"></span>',
      :add_link       => "||FORM LINK||"
    }
    wrapper = Theme.parse_wrapper(opts[:wrapper], wrapper_tokens)
    
    # parse testimonial.html
    tokens = Testimonial.api_attributes
    testimonial = Theme.parse_testimonial(opts[:testimonial], tokens)

    context.render_to_string(
      :partial => "testimonials/theme_config",
      :locals  => {
        :apikey             => opts[:user].apikey,
        :stylesheet         => opts[:stylesheet],
        :wrapper_html       => wrapper,
        :testimonial_html   => testimonial
      }
    )
  end

  def self.names_for_select
    names = []
    self.names.each_with_index {|k,v| names.push([ k, v ]) }
    names
  end
     
end