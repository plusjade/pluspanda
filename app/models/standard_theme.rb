class StandardTheme < Theme

  
  def self.names
    [
      "bernd",
      "bernd-simple",
      "legacy",
      "custom"
    ]
  end
      
  # here we populate the associated attributes.
  # we get these from the associated theme dir. 
  # note the data should already be verified and sanitized.
  def populate_attributes
    attributes = ThemeAttribute.names
    theme_path = File.join(Themes_path, StandardTheme.names[self.name])
    
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
  
  
  def self.parse_testimonial(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) { |tkn|
      tokens.include?($1.to_sym) ? "'+item.#{$1.to_s}+'" : tkn
    }
  end
  

  def self.parse_wrapper(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) { |tkn|
      tokens.has_key?($1.to_sym) ? tokens[$1.to_sym].gsub("{{param}}", $2) : tkn
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
    wrapper = StandardTheme.parse_wrapper(opts[:wrapper], wrapper_tokens)
    
    # parse testimonial.html for tokens
    tokens = Testimonial.api_attributes
    testimonial = StandardTheme.parse_testimonial(opts[:testimonial], tokens)

    if Rails.env.development?
      widget_url = "/javascripts/widget/widget.js"
      facebox_url = "/javascripts/widget/facebox.js"
    else  
      widget_url = Storage.new().widget_url
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

  
  
end

