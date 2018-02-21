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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180221164000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "drivers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "provider_id"
    t.index ["provider_id"], name: "index_drivers_on_provider_id"
    t.index ["user_id"], name: "index_drivers_on_user_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "runs", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "driver_id"
    t.date "date"
    t.boolean "complete"
    t.index ["driver_id"], name: "index_runs_on_driver_id"
    t.index ["provider_id"], name: "index_runs_on_provider_id"
  end

  create_table "trips", force: :cascade do |t|
    t.bigint "run_id"
    t.bigint "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_trips_on_provider_id"
    t.index ["run_id"], name: "index_trips_on_run_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "email"
    t.string "password"
    t.string "password_confirmation"
    t.string "authentication_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "drivers", "users"
  add_foreign_key "trips", "providers"
  add_foreign_key "trips", "runs"
end
