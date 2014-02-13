# Handles generic processing for pluspanda themes.
class Theme < ActiveRecord::Base
  # set filenames to be used for s3
  # Note {{apikey}} is replaced with the user's apikey
  StylesheetFilename = "data/{{apikey}}/style.css"
  ThemeConfigFilename = "data/{{apikey}}/theme_config.js"

  # matches {{blah_token}}, {{blah_token:param}}
  Token_regex = /\{{2}(\w+):?([\w\s?!:"',\.]*)\}{2}/i
  Themes_path = Rails.root.join("public/_pAndAThemeS_")

  # this should only be used in gallery view for direct css
  #Themes_url  = "_pAndAThemeS_"
  Themes_url  = "http://s3.amazonaws.com/pluspanda/themes"

  belongs_to :user
  has_many :theme_attributes, :dependent => :destroy
  after_create :populate_attributes

  # The order of these matter because we store the index position to denote installed theme =/
  Names = %w{
      bernd
      bernd-simple
      legacy
      custom
      modern
    }

  # return the currently staged theme
  def self.get_staged
    theme = self.find_by_staged(true)
    if theme.nil?
      theme = self.first
      theme.staged = true
      theme.save
    end
    
    theme
  end

  def name_human
    Names[name]
  end

  # Get the standard theme attribute
  # we always get the staged theme-attributes
  def get_attribute(attribute)
    self.theme_attributes.find_by_name(ThemeAttribute.names.index(attribute))
  end

  # here we populate the associated attributes.
  # we get these from the associated theme dir. 
  # note the data should already be verified and sanitized.
  def populate_attributes
    # attributes are white-listed and then included if the theme has
    # a filename of the same attribute name.

    attributes = ThemeAttribute.names
    theme_path = File.join(Themes_path, name_human)

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

  def publish
    publish_css
    publish_theme_config
  end

  def publish_css
    f = File.new(tmp_stylesheet_path, "w+")
    f.write(generate_css)
    f.rewind

    Storage.store(stylesheet_filename, tmp_stylesheet_path, content_type: "text/css")
  end
  
  # HTML is packaged in the theme_config
  # This is for the standard theme
  def publish_theme_config
    f = File.new(tmp_theme_config_path, "w+")
    f.write(self.generate_theme_config)
    f.rewind

    Storage.store(theme_config_filename, tmp_theme_config_path)
  end

  def generate_css
    css = get_attribute("style.css").staged
    facebox_path = Rails.root.join("public","stylesheets","facebox.css")
    if File.exist?(facebox_path)
      css << "\n" << File.new(facebox_path).read
    end
    css
  end

  def generate_theme_config(for_staging=false)
    self.class.render_theme_config({
      :user         => self.user,
      :stylesheet   => for_staging ? "" : self.stylesheet_url,
      :wrapper      => self.get_attribute("wrapper.html").staged,
      :testimonial  => self.get_attribute("testimonial.html").staged
    })
  end

  # A theme attribute is defined in the theme folder as a file
  def self.render_theme_attribute(theme, attribute)
    attributes = ThemeAttribute.names
    path = File.join(Themes_path, theme, attribute)

    if attributes.include?(attribute) && File.exist?(path)
      File.new(path).read
    end
  end

  # parses the theme wrapper attribute
  def self.parse_wrapper(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) { |tkn|
      tokens.has_key?($1.to_sym) ? tokens[$1.to_sym].gsub("{{param}}", $2) : tkn
    }
  end

  def self.parse_testimonial(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) { |tkn|
      tokens.include?($1.to_sym) ? "'+item.#{$1.to_s}+'" : tkn
    }
  end

  # builds the theme_config js file.
  # Note this is the main file users include on their site.
  # This file is responsible for bootstrapping the widget.
  # We push this to s3 and redirect to it from our api widget.js call
  def self.render_theme_config(opts)
    context = ApplicationController.new
    opts[:user]         ||= nil
    opts[:stylesheet]   ||= ""
    opts[:wrapper]      ||= ""
    opts[:testimonial]  ||= ""
    
    # parse wrapper.html for tokens
    tag_list = context.render_to_string(
      :partial  => "testimonials/tag_list",
      :locals   => { :tags => Tag.where({:user_id => opts[:user].id }) }
    ).gsub(/[\n\r\t]/,'')    
    wrapper_tokens = {
      :tag_list       => tag_list,
      :count          => '<span class="pandA-tCount_ness"></span>',
      :testimonials   => '<span class="pandA-tWrapper_ness"></span>',
      :form_link      => '<a href="#" class="pandA-addForm_ness">{{param}}</a>'
    }
    wrapper = parse_wrapper(opts[:wrapper], wrapper_tokens)
    
    # parse testimonial.html for tokens
    tokens = Testimonial.api_attributes
    testimonial = parse_testimonial(opts[:testimonial], tokens)

    if Rails.env.development?
      widget_url = "/javascripts/widget/widget.js"
      facebox_url = "/javascripts/widget/facebox.js"
    else  
      widget_url = Storage.standard_widget_url
      facebox_url = Storage.facebox_url
    end

    context.render_to_string(
      :partial => "testimonials/theme_config",
      :locals  => {
        :apikey             => opts[:user].apikey,
        :stylesheet         => opts[:stylesheet],
        :wrapper_html       => wrapper,
        :testimonial_html   => testimonial,
        :widget_url         => widget_url,
        :facebox_url        => facebox_url 
      }
    )
  end

  def tmp_stylesheet_path
    Rails.root.join("tmp", "#{user.apikey}.css")
  end

  def tmp_theme_config_path
    Rails.root.join("tmp", "#{user.apikey}.js")
  end


  # s3 filenames and urls
  # =====================

  def stylesheet_filename
    StylesheetFilename.gsub("{{apikey}}", user.apikey)
  end

  # the published stylesheet is NOT theme specific.
  def stylesheet_url
    Storage.url(stylesheet_filename)
  end

  def theme_config_filename
    ThemeConfigFilename.gsub("{{apikey}}", user.apikey)
  end

  def theme_config_url
    Storage.url(theme_config_filename)
  end
end
