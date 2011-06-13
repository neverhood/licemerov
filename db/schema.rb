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

ActiveRecord::Schema.define(:version => 20110613131905) do

  create_table "albums", :force => true do |t|
    t.integer  "user_id",         :default => 0,                     :null => false
    t.string   "cover",           :default => "/images/missing.png"
    t.string   "title",           :default => "",                    :null => false
    t.string   "description"
    t.string   "latinized_title",                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",           :default => 0
    t.integer  "friend_id",         :default => 0
    t.boolean  "approved",          :default => false
    t.boolean  "canceled",          :default => false
    t.boolean  "marked_as_deleted", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "user_id",           :default => 0,     :null => false
    t.integer  "receiver_id",       :default => 0,     :null => false
    t.boolean  "read",              :default => false, :null => false
    t.text     "body",              :default => "",    :null => false
    t.string   "subject"
    t.boolean  "marked_as_deleted", :default => false, :null => false
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_comments", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.integer  "photo_id",                   :null => false
    t.text     "body",       :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_ratings", :force => true do |t|
    t.integer  "photo_id"
    t.integer  "rater_id"
    t.integer  "user_id"
    t.integer  "rating"
    t.string   "item"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.integer  "album_id"
    t.integer  "user_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "photo_dimensions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "views",              :default => 0
    t.string   "permissions"
  end

  create_table "profile_comments", :force => true do |t|
    t.integer  "user_id",                            :null => false
    t.integer  "author_id",                          :null => false
    t.integer  "parent_id"
    t.text     "body",               :default => "", :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "root_entries", :force => true do |t|
    t.integer  "user_id",            :default => 0
    t.integer  "mood",               :default => 0
    t.text     "body",               :default => ""
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_details", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birth_date"
    t.string   "country"
    t.string   "city"
    t.string   "phone"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",               :default => "", :null => false
    t.string   "email",               :default => "", :null => false
    t.string   "crypted_password",    :default => "", :null => false
    t.string   "password_salt",       :default => "", :null => false
    t.string   "persistence_token",   :default => "", :null => false
    t.string   "single_access_token", :default => "", :null => false
    t.string   "perishable_token",    :default => "", :null => false
    t.integer  "sex",                 :default => 1,  :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "avatar_dimensions"
    t.integer  "login_count",         :default => 0,  :null => false
    t.integer  "failed_login_count",  :default => 0,  :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
