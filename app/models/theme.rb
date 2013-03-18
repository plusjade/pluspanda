# Handles generic processing for pluspanda themes.
# Note we use single table inheritance to use different themes based on widget.
# Notably:
#
# - StandardTheme (original format themes)
#
class Theme < ActiveRecord::Base

  belongs_to :user
  has_many :theme_attributes, :dependent => :destroy
  after_create :populate_attributes

  # matches {{blah_token}}, {{blah_token:param}}
  Token_regex = /\{{2}(\w+):?([\w\s?!:"',\.]*)\}{2}/i
  Themes_path = Rails.root.join("public/_pAndAThemeS_")

  # this should only be used in gallery view for direct css
  #Themes_url  = "_pAndAThemeS_"
  Themes_url  = "http://s3.amazonaws.com/pluspanda/themes"

  # Get the standard theme attribute
  # we always get the staged theme-attributes
  def get_attribute(attribute)
    self.theme_attributes.find_by_name(ThemeAttribute.names.index(attribute))
  end
  
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
  
  # A theme attribute is defined in the theme folder as a file
  def self.render_theme_attribute(theme, attribute)
    attributes = ThemeAttribute.names
    path = File.join(Themes_path, theme, attribute)

    if attributes.include?(attribute) && File.exist?(path)
      File.new(path).read
    end

  end
  
  # here we populate the associated attributes.
  # we get these from the associated theme dir. 
  # note the data should already be verified and sanitized.
  def populate_attributes
    # attributes are white-listed and then included if the theme has
    # a filename of the same attribute name.
    attributes = ThemeAttribute.names
    theme_path = File.join(Themes_path, self.class.names[self.name])
    
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
  
  # parses the theme wrapper attribute
  def self.parse_wrapper(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) { |tkn|
      tokens.has_key?($1.to_sym) ? tokens[$1.to_sym].gsub("{{param}}", $2) : tkn
    }
  end
  
  def tmp_stylesheet_path
    Rails.root.join("tmp", "#{user.apikey}.css")
  end

  def tmp_theme_config_path
    Rails.root.join("tmp", "#{user.apikey}.js")
  end
  
end