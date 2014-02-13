require 'sanitize'
class ThemeAttribute < ActiveRecord::Base

  belongs_to :theme
  before_save :sanitize

  # IMPORTANT. Names are saved by their array index value.
  # DO NOT reorder these.
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
    unless self.name == 2
      self.staged = Sanitize.clean(self.staged.to_s, SANITIZE_CONFIG)
    end
  end
end
