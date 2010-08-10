class User < ActiveRecord::Base
  acts_as_authentic
  before_create :generate_defaults
  
  def generate_defaults 
    self.apikey = ActiveSupport::SecureRandom.hex(8)
  end
end
