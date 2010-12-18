class ThemeAttribute < ActiveRecord::Base

  belongs_to :theme

  def self.names
    [
      "wrapper.html",
      "testimonial.html",
      "style.css",
      "modal.css"
    ]
  end

=begin
  @user.theme.theme_attributes

    id| theme_id | name | published | staged | original
=end
  
end