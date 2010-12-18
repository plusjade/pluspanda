class Theme < ActiveRecord::Base

  belongs_to :user
  has_many :theme_attributes, :dependent => :destroy
      
  after_create :populate_attributes

  
  # here we populate the associated attributes.
  # we get these from the associated theme dir. 
  # note the data should already be verified and sanitized.
  def populate_attributes
    attributes = ThemeAttribute.names
    theme_path = Rails.root.join("public/themes/#{Theme.names[self.name]}")
    
    if File.exist?(theme_path)
      Dir.new(theme_path).each do |file|
        next if file.index('.') == 0
        if attributes.include?(file)
          contents =  File.new("#{theme_path}/#{file}").read
          self.theme_attributes.create(
            :name     => attributes.index(file), 
            :staged   => contents,
            :original => contents
          )
        end
      end
    end
    
  end
  

  def self.names
    [
      "list",
      "simple",
      "legacy",
      "custom"
    ]
  end

  def self.names_for_select
    names = []
    self.names.each_with_index {|k,v| names.push([ k, v ]) }
    names
  end  
  
  
=begin
 theme
  id | theme | staged | published

  ** a theme can be both staged and published.

  basic users can work with 2 themes at a time.
  installing a new theme creates a new theme row.
  the new theme row populates the theme_attributes
  loading a theme in admin flags it as staged.
  publishing a theme flags it as published


  the staging environment will dynamically serve the staged theme.
  publishing a theme will save/parse and cache the results to:
    -data/apikey/published.blah

=end  
  
end