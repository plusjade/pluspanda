# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101213032133) do

  create_table "tags", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "desc"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tconfigs", :force => true do |t|
    t.integer  "user_id"
    t.string   "theme"
    t.string   "sort"
    t.integer  "per_page"
    t.text     "form"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "testimonials", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tag_id"
    t.string   "token"
    t.string   "name"
    t.string   "company"
    t.string   "c_position"
    t.string   "location"
    t.string   "url"
    t.text     "body"
    t.text     "body_edit"
    t.integer  "rating"
    t.boolean  "publish",          :default => false
    t.integer  "position"
    t.boolean  "lock",             :default => false
    t.string   "email"
    t.string   "meta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name", :default => "",    :null => false
    t.boolean  "trash",            :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "apikey",                             :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.datetime "last_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

  create_table "widget_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "impressions", :default => 0
  end

end
