# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20120111195717) do

  create_table "addresses", :force => true do |t|
    t.string   "firstname",  :null => false
    t.string   "lastname",   :null => false
    t.string   "address1",   :null => false
    t.string   "address2"
    t.string   "city",       :null => false
    t.string   "state_id",   :null => false
    t.string   "zip",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_images", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "image_id"
  end

  create_table "countries", :force => true do |t|
    t.string  "name"
    t.string  "abbr"
    t.boolean "active_shipping", :default => false
    t.boolean "active_billing",  :default => false
  end

  create_table "credits", :force => true do |t|
    t.integer  "order_id"
    t.string   "source_type"
    t.integer  "source_id"
    t.decimal  "total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "title",                                   :null => false
    t.string   "slug",                                    :null => false
    t.text     "description"
    t.integer  "user_id",                                 :null => false
    t.string   "gallery_file_name"
    t.string   "gallery_content_type"
    t.string   "gallery_file_size"
    t.datetime "gallery_updated_at"
    t.string   "main_file_name"
    t.string   "main_content_type"
    t.string   "main_file_size"
    t.datetime "main_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_featured",          :default => false, :null => false
  end

  create_table "line_items", :force => true do |t|
    t.integer "order_id",   :null => false
    t.integer "quantity",   :null => false
    t.integer "variant_id", :null => false
    t.decimal "total"
  end

  create_table "orders", :force => true do |t|
    t.integer  "billing_address_id",  :null => false
    t.integer  "shipping_address_id", :null => false
    t.integer  "user_id"
    t.string   "email",               :null => false
    t.string   "phone",               :null => false
    t.decimal  "total",               :null => false
    t.decimal  "total_due",           :null => false
    t.decimal  "tax_charge",          :null => false
    t.string   "status",              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_method_values", :force => true do |t|
    t.integer "payment_method_id"
    t.string  "key"
    t.string  "value"
  end

  create_table "payment_methods", :force => true do |t|
    t.string   "description",                    :null => false
    t.string   "klass",                          :null => false
    t.boolean  "active",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.integer  "order_id"
    t.integer  "payment_method_id"
    t.string   "status",            :default => "paid", :null => false
    t.decimal  "total",             :default => 0.0,    :null => false
    t.integer  "month"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transaction_id"
  end

  create_table "posts", :force => true do |t|
    t.string   "title",      :null => false
    t.string   "slug",       :null => false
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "shipments", :force => true do |t|
    t.integer  "order_id",                              :null => false
    t.integer  "shipping_method_id",                    :null => false
    t.string   "status",             :default => "new", :null => false
    t.decimal  "total",              :default => 0.0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipping_method_values", :force => true do |t|
    t.integer "shipping_method_id"
    t.string  "key"
    t.string  "value"
  end

  create_table "shipping_methods", :force => true do |t|
    t.string  "description",                    :null => false
    t.string  "klass",                          :null => false
    t.boolean "active",      :default => false, :null => false
  end

  create_table "states", :force => true do |t|
    t.string  "abbr"
    t.string  "name"
    t.integer "country_id"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tax_method_values", :force => true do |t|
    t.integer "tax_method_id"
    t.string  "key"
    t.string  "value"
  end

  create_table "tax_methods", :force => true do |t|
    t.string  "description",                    :null => false
    t.string  "klass",                          :null => false
    t.boolean "active",      :default => false, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "display_name",                                          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "variants", :force => true do |t|
    t.string  "sku",                                    :null => false
    t.string  "description",                            :null => false
    t.decimal "price",                                  :null => false
    t.integer "quantity",            :default => 0,     :null => false
    t.integer "item_id",                                :null => false
    t.string  "item_type",                              :null => false
    t.boolean "active",              :default => false, :null => false
    t.boolean "unlimited_inventory", :default => false, :null => false
  end

end
