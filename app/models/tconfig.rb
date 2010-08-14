class Tconfig < ActiveRecord::Base
  serialize :form, Hash
  belongs_to :user
  before_save {self.form = self.form.inject({}) { |h,(k,v)| h[k] = v.strip ; h }}
  # No clue why this does not work: (because of the yamlesq Hash difference?)
    #before_save { self.form = self.form.merge(self.form){ |k,ov| ov.strip } }
  before_create :generate_defaults
  
  def generate_defaults 
    self.theme     ||= 'list'
    self.sort      ||= 'created'
    self.per_page  ||= 10    
  end
      
end
