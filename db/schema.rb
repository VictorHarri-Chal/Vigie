# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_04_03_142739) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "logs", force: :cascade do |t|
    t.string "log_id"
    t.string "event_type"
    t.datetime "occurred_at"
    t.jsonb "payload"
    t.datetime "imported_at"
    t.bigint "pav_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_logs_on_event_type"
    t.index ["log_id"], name: "index_logs_on_log_id", unique: true
    t.index ["occurred_at"], name: "index_logs_on_occurred_at"
    t.index ["pav_id"], name: "index_logs_on_pav_id"
    t.index ["payload"], name: "index_logs_on_payload", using: :gin
  end

  create_table "pavs", force: :cascade do |t|
    t.string "pav_id"
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "zip"
    t.float "lat"
    t.float "lng"
    t.string "waste_type"
    t.integer "capacity_liters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pav_id"], name: "index_pavs_on_pav_id", unique: true
    t.index ["waste_type"], name: "index_pavs_on_waste_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "logs", "pavs"
end
