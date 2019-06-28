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

ActiveRecord::Schema.define(version: 2019_06_24_020011) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "club_memberships", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_club_memberships_on_club_id"
    t.index ["user_id", "club_id"], name: "index_club_memberships_on_user_id_and_club_id", unique: true
    t.index ["user_id"], name: "index_club_memberships_on_user_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.string "uid", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_clubs_on_creator_id"
    t.index ["uid"], name: "index_clubs_on_uid", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.bigint "black_opponent_id"
    t.bigint "white_opponent_id"
    t.text "moves"
    t.boolean "white_turn", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["black_opponent_id"], name: "index_games_on_black_opponent_id"
    t.index ["white_opponent_id"], name: "index_games_on_white_opponent_id"
  end

  create_table "pieces", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "type", null: false
    t.integer "color", null: false
    t.string "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_pieces_on_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "display_name", default: "Anonymous", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "club_memberships", "clubs"
  add_foreign_key "club_memberships", "users"
  add_foreign_key "clubs", "users", column: "creator_id"
  add_foreign_key "games", "users", column: "black_opponent_id"
  add_foreign_key "games", "users", column: "white_opponent_id"
  add_foreign_key "pieces", "games"
end
