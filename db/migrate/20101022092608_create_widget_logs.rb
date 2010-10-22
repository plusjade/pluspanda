class CreateWidgetLogs < ActiveRecord::Migration
  def self.up
    create_table :widget_logs do |t|
      t.references  :user
      t.string      :url
      t.timestamps
    end
  end

  def self.down
    drop_table :widget_logs
  end
end
