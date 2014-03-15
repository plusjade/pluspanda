# == Schema Information
#
# Table name: themes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :integer
#  staged     :boolean          default(FALSE)
#  published  :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  type       :string(255)
#  theme_name :string(255)
#

# Deprecated
class StandardTheme < Theme
end
