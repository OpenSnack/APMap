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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aps", id: false, force: :cascade do |t|
    t.uuid   "site",                null: false
    t.string "hostname", limit: 80, null: false
    t.float  "x_pos"
    t.float  "y_pos"
    t.string "weburl",   limit: 50
    t.string "jsonurl",  limit: 50
    t.string "name",     limit: 80
  end

  create_table "sites", id: false, force: :cascade do |t|
    t.uuid   "uuid",                 default: "uuid_generate_v4()", null: false
    t.string "name",     limit: 30,                                 null: false
    t.string "comment",  limit: 150
    t.string "map",      limit: 150
  end

  add_index "sites", ["uuid"], name: "sites_uuid_key", unique: true, using: :btree

  add_foreign_key "aps", "sites", column: "site", primary_key: "uuid", name: "aps_site_fkey", on_delete: :cascade
end
