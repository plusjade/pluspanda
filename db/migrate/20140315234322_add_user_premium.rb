class AddUserPremium < ActiveRecord::Migration
  def up
    unless column_exists? :users, :premium
      add_column :users, :premium, :boolean, default: false
    end
  end

  def down
    remove_column :users, :premium
  end
end
