# == Schema Information
#
# Table name: widget_logs
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  url         :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  impressions :integer          default(0)
#

class WidgetLog < ActiveRecord::Base

  belongs_to :user
end
