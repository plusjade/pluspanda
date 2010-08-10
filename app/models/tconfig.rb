class Tconfig < ActiveRecord::Base

  belongs_to :user
  
  before_create :generate_defaults
  
  def generate_defaults 
    self.theme     ||= 'list'
    self.sort      ||= 'created'
    self.per_page  ||= 10    
  end
      
end
