class CreateTestimonials < ActiveRecord::Migration
  def self.up
    create_table :testimonials do |t|
      t.references  :user
      t.references  :tag
      t.string      :token 
      t.string      :name
      t.string      :company
      t.string      :c_position
      t.string      :location
      t.string      :url
      t.text        :body
      t.text        :body_edit
      t.integer     :rating
      # image stuff
      t.boolean     :publish,     :default => false
      t.integer    :position
      t.boolean     :lock,        :default => false
      t.string      :email
      t.string      :meta
      t.timestamps
    end
  end

  def self.down
    drop_table :testimonials
  end
end
