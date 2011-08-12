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


  # A theme attribute is defined in the theme folder as a file
  def self.render_theme_attribute(theme, attribute)
    attributes = ThemeAttribute.names
    path = File.join(Themes_path, theme, attribute)

    if attributes.include?(attribute) && File.exist?(path)
      File.new(path).read
    end

  end
  
end