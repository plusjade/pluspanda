require 'fileutils'

class ThemePackage
  Path = Rails.root.join("public/_pAndAThemeS_")

  def self.themes
    Path.children(false).map{ |a| a.to_s }
  end

  def initialize(theme_name)
    unless self.class.themes.include?(theme_name)
      raise "Theme #{ theme_name } not found in #{ self.class.themes }" 
    end

    @path = File.join(Path, theme_name)
  end

  def attributes
    FileUtils.cd(@path) { return Dir.glob('*.*') }
  end

  def get_attribute(attribute_name)
    filepath = File.join(@path, attribute_name)
    File.exist?(filepath) ? File.new(filepath).read : "/*No data*/"
  end
end
