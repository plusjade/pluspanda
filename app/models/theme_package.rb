require 'sass'
require 'fileutils'

class ThemePackage
  Path = Rails.root.join("public/theme-packages")
  attr_reader :theme_name

  def self.themes
    Path.children(false).map{ |a| a.to_s }
  end

  def self.default_theme
    default = "modern"
    raise "Cannot find default theme!" unless themes.include?(default)
    default
  end

  def initialize(theme_name)
    unless self.class.themes.include?(theme_name)
      raise "Theme '#{ theme_name }' not found in #{ self.class.themes }" 
    end

    @theme_name = theme_name
    @path = File.join(Path, theme_name)
  end

  def attributes
    FileUtils.cd(@path) { return Dir.glob('*.*') }
  end

  # TODO: Cleanup hack to support scss files.
  def get_attribute(attribute_name)
    filepath = File.join(@path, attribute_name)
    ext = File.extname(filepath)
    unless File.exist?(filepath)
      if %w(.css .scss).include?(ext)
        filepath = filepath.gsub(Regexp.new("#{ ext }$"), (ext == ".css") ? ".scss" : ".css")
      end

      return "/*No data*/" unless File.exist?(filepath)
    end

    if %w(.css .scss).include?(ext)
      template = File.open(filepath).read
      Sass::Engine.new(template, syntax: :scss).render
    else
      File.new(filepath).read
    end
  end
end
