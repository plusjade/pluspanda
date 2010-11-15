class AddLogCount < ActiveRecord::Migration
  def self.up
     change_table :widget_logs do |t|
       t.integer :impressions, :default => 0
     end
  end

  def self.down
  end
end
