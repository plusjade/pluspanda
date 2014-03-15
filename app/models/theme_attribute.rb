# == Schema Information
#
# Table name: theme_attributes
#
#  id             :integer          not null, primary key
#  theme_id       :integer
#  name           :integer
#  published      :text
#  staged         :text
#  original       :text
#  created_at     :datetime
#  updated_at     :datetime
#  attribute_name :string(255)
#

require 'sanitize'
class ThemeAttribute < ActiveRecord::Base

  belongs_to :theme
  before_save :sanitize

  Names = %w{
    wrapper.html
    testimonial.html
    style.css
    modal.css
  }

  SANITIZE_CONFIG  = {
    :elements => [
      'div','span','br','h1','h2','h3','h4','h5','h6','p','blockquote','pre','a','abbr','acronym','address','big','cite','code','del','dfn','em','font','img','ins','kbd','q','s','samp','small','strike','strong','sub','sup','tt','var','b','u','i','center','dl','dt','dd','ol','ul','li','table','caption','tbody','tfoot','thead','tr','th','td'
    ],
    :attributes => {
      :all  => ['id','class','title','rel','style'],
      'a'   => ['href'],
      'img' => ['src','alt', 'height', 'width']
    }
  }

  def sanitize
    if ["wrapper.html", "testimonial.html"].include?(attribute_name)
      self.staged = Sanitize.clean(staged.to_s, SANITIZE_CONFIG)
    end
  end

  def self.migrate
    %w{
        wrapper.html
        testimonial.html
        style.css
        modal.css
      }.each_with_index do |name, i |
        ThemeAttribute.update_all({ attribute_name: name }, { name: i })
      end
  end
end
