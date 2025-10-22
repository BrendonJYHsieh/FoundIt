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

ActiveRecord::Schema[8.0].define(version: 2025_10_21_153622) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "found_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "item_type"
    t.text "description"
    t.string "location"
    t.datetime "found_date"
    t.text "photos"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_found_items_on_user_id"
  end

  create_table "lost_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "item_type"
    t.text "description"
    t.string "location"
    t.datetime "lost_date"
    t.text "verification_questions"
    t.text "photos"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_lost_items_on_user_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "lost_item_id", null: false
    t.integer "found_item_id", null: false
    t.float "similarity_score"
    t.string "status"
    t.text "verification_answers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["found_item_id"], name: "index_matches_on_found_item_id"
    t.index ["lost_item_id"], name: "index_matches_on_lost_item_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "uni"
    t.string "password_digest"
    t.boolean "verified"
    t.integer "reputation_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "found_items", "users"
  add_foreign_key "lost_items", "users"
  add_foreign_key "matches", "found_items"
  add_foreign_key "matches", "lost_items"
end
