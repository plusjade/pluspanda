class UsersStripeId < ActiveRecord::Migration
  def up
    unless column_exists? :users, :stripe_id
      add_column :users, :stripe_id, :string
    end
  end

  def down
    remove_column :users, :stripe_id
  end
end
