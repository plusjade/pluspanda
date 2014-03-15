# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)
#  desc       :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

class Tag < ActiveRecord::Base

  belongs_to :testimonial
end
