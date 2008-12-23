# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081223192604) do
  create_table "accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "state",             :default => "pending"
  end
  
  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "subscription_addresses", :force => true do |t|
    t.text     "street"
    t.string   "city"
    t.string   "region"
    t.string   "postcode"
    t.string   "country"
    t.string   "invoice_to"
    t.integer  "subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_profiles", :force => true do |t|
    t.integer  "subscription_id",              :null => false
    t.integer  "recurring_payment_profile_id", :null => false
    t.datetime "created_at",                   :null => false
  end

  add_index "subscription_profiles", ["subscription_id"], :name => "ix_subscription_profiles_subscription"

  create_table "subscriptions", :force => true do |t|
    t.integer  "account_id"
    t.string   "state",             :default => "pending"
    t.string   "plan_name",                                :null => false
    t.string   "auth_code"
    t.text     "last_charge_error"
    t.datetime "next_renewal_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "subscription_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.text     "meta"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.string   "identity_url"
    t.integer  "account_id"
    t.string   "state",                                    :default => "pending"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["identity_url"], :name => "index_users_on_identity_url"
end
