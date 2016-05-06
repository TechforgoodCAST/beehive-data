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

ActiveRecord::Schema.define(version: 20160505143840) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beneficiaries", force: :cascade do |t|
    t.string   "label"
    t.string   "sort"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "beneficiaries_grants", force: :cascade do |t|
    t.integer "beneficiary_id"
    t.integer "grant_id"
  end

  create_table "grants", force: :cascade do |t|
    t.string   "grant_identifier"
    t.string   "funder_identifier"
    t.string   "recipient_identifier"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "grants", ["funder_identifier"], name: "index_grants_on_funder_identifier", using: :btree
  add_index "grants", ["grant_identifier"], name: "index_grants_on_grant_identifier", unique: true, using: :btree
  add_index "grants", ["recipient_identifier"], name: "index_grants_on_recipient_identifier", using: :btree

end
