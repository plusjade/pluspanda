# == Schema Information
#
# Table name: tconfigs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  theme      :string(255)
#  sort       :string(255)
#  per_page   :integer
#  form       :text
#  message    :text
#  created_at :datetime
#  updated_at :datetime
#

class Tconfig < ActiveRecord::Base
  serialize :form, Hash
  belongs_to :user
  before_create :generate_defaults
  before_save   :format


  def generate_defaults 
    self.theme     ||= 'list'
    self.sort      ||= 'created'
    self.per_page  ||= 10 
    self.form      ||= {
      "meta"        => "",
      "require_key" => "",
      #"email"       => ""
    }
  end


  # No clue why this does not work: (because of the yamlesq Hash difference?)
    #before_save { self.form = self.form.merge(self.form){ |k,ov| ov.strip } }
  def format
    if self.form.is_a?(Hash)
      self.form = self.form.inject({}) { |h,(k,v)| h[k] = v.strip ; h }
    end
  end
  
  def self.themes
    ['list','simple','legacy']
  end    
  
  def self.sorters
    {
      'Creation Date' => 'created',
      'Custom Positions' => 'position'
    }
  end
  
  
end
