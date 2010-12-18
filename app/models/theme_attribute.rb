class ThemeAttribute < ActiveRecord::Base

  belongs_to :theme
=begin
  @user.theme.theme_attributes

    id| theme_id | type | published | staged | original
=end
  
  
  def self.names
    [
      "wrapper.html",
      "testimonial.html",
      "style.css",
      "modal.css"
    ]
  end


end