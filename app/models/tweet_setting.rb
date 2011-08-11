class TweetSetting < ActiveRecord::Base
  belongs_to :user
  before_create :generate_defaults

  def generate_defaults 
    self.theme     ||= 'tweets'
    self.sort      ||= 'created'
    self.per_page  ||= 5 
  end

  
  def self.themes
    ['tweets']
  end    
  
  def self.sorters
    {
      'Creation Date' => 'created',
      'Custom Positions' => 'position'
    }
  end


end
