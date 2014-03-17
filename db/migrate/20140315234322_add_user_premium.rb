class AddUserPremium < ActiveRecord::Migration
  def up
    add_column :users, :premium, :boolean, default: false
  end

  def down
    remove_column :users, :premium
  end
end
