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

end