# Handles theme processing for standard (original format) testimonials
# For notes see Theme model
class StandardTheme < Theme

  def self.names
    [
      "bernd",
      "bernd-simple",
      "legacy",
      "custom"
    ]
  end

  def self.parse_testimonial(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) { |tkn|
      tokens.include?($1.to_sym) ? "'+item.#{$1.to_s}+'" : tkn
    }
  end
  
  def publish
    publish_css
    publish_theme_config
  end

  def publish_css
    storage = Storage.new(self.user.apikey)
    storage.connect
    storage.add_standard_theme_stylesheet(generate_css)
  end
  
  # HTML is packaged in the theme_config
  # This is for the standard theme
  def publish_theme_config
    storage = Storage.new(self.user.apikey)
    storage.connect
    storage.add_theme_config(generate_theme_config)
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
    StandardTheme.render_theme_config({
      :user         => self.user,
      :stylesheet   => for_staging ? "" : self.theme_stylesheet_url,
      :wrapper      => self.get_attribute("wrapper.html").staged,
      :testimonial  => self.get_attribute("testimonial.html").staged
    })    
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
    wrapper = Theme.parse_wrapper(opts[:wrapper], wrapper_tokens)
    
    # parse testimonial.html for tokens
    tokens = Testimonial.api_attributes
    testimonial = StandardTheme.parse_testimonial(opts[:testimonial], tokens)

    if Rails.env.development?
      widget_url = "/javascripts/widget/widget.js"
      facebox_url = "/javascripts/widget/facebox.js"
    else  
      widget_url = Storage.new().standard_widget_url
      facebox_url = Storage.new().facebox_url
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

  
  def theme_stylesheet_url
    Storage.new(self.user.apikey).standard_theme_stylesheet_url
  end
  
  
end

