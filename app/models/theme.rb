# == Schema Information
#
# Table name: themes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :integer
#  staged     :boolean          default(FALSE)
#  published  :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  type       :string(255)
#  theme_name :string(255)
#

# Handles generic processing for pluspanda themes.
class Theme < ActiveRecord::Base
  belongs_to :user
  has_many :theme_attributes, :dependent => :destroy
  after_create :populate_attributes

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

  def theme_package
    @theme_package ||= ThemePackage.new(theme_name)
  end

  # Get the standard theme attribute
  # we always get the staged theme-attributes
  def get_attribute(attribute_name)
    theme_attributes.find_by_attribute_name(attribute_name) ||
      populate_attribute(attribute_name)
  end

  # here we populate the associated attributes.
  # we get these from the associated theme dir. 
  # note the data should already be verified and sanitized.
  def populate_attributes
    theme_package.attributes.each{ |attribute_name| populate_attribute(attribute_name) }
  end

  def populate_attribute(attribute_name)
    contents = theme_package.get_attribute(attribute_name)
    theme_attributes.create(
      :attribute_name => attribute_name,
      :staged   => contents,
      :original => contents
    )
  end

  def publish
    Publish::Stylesheet.new(user.apikey).publish(generate_css)
    Publish::Config.new(user.apikey).publish(generate_theme_config)
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
    ThemeConfig.render({
      :user         => self.user,
      :stylesheet   => for_staging ? "" : Publish::Stylesheet.new(user.apikey).endpoint,
      :wrapper      => self.get_attribute("wrapper.html").staged,
      :testimonial  => self.get_attribute("testimonial.html").staged
    })
  end

  def self.migrate
    %w{
        bernd
        bernd-simple
        legacy
        custom
        modern
      }.each_with_index do |name, i|
      StandardTheme.update_all({ theme_name: name }, { name: i })
    end
  end
end
