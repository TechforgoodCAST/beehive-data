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

ActiveRecord::Schema.define(version: 20160506115639) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "age_groups", force: :cascade do |t|
    t.string   "label"
    t.string   "age_from"
    t.string   "age_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "age_groups", ["age_from"], name: "index_age_groups_on_age_from", using: :btree
  add_index "age_groups", ["age_to"], name: "index_age_groups_on_age_to", using: :btree
  add_index "age_groups", ["label"], name: "index_age_groups_on_label", using: :btree

  create_table "age_groups_grants", force: :cascade do |t|
    t.integer "age_group_id"
    t.integer "grant_id"
  end

  create_table "beneficiaries", force: :cascade do |t|
    t.string   "label"
    t.string   "sort"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "beneficiaries", ["label"], name: "index_beneficiaries_on_label", using: :btree
  add_index "beneficiaries", ["sort"], name: "index_beneficiaries_on_sort", using: :btree

  create_table "beneficiaries_grants", force: :cascade do |t|
    t.integer  "beneficiary_id"
    t.integer  "grant_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "beneficiaries_grants", ["beneficiary_id"], name: "index_beneficiaries_grants_on_beneficiary_id", using: :btree
  add_index "beneficiaries_grants", ["grant_id"], name: "index_beneficiaries_grants_on_grant_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "name"
    t.string   "alpha2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "countries", ["alpha2"], name: "index_countries_on_alpha2", using: :btree
  add_index "countries", ["name"], name: "index_countries_on_name", using: :btree

  create_table "countries_grants", force: :cascade do |t|
    t.integer "country_id"
    t.integer "grant_id"
  end

  create_table "districts", force: :cascade do |t|
    t.integer  "country_id"
    t.string   "name"
    t.string   "subdivision"
    t.string   "region"
    t.string   "sub_country"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "districts", ["country_id"], name: "index_districts_on_country_id", using: :btree
  add_index "districts", ["name"], name: "index_districts_on_name", using: :btree

  create_table "districts_grants", force: :cascade do |t|
    t.integer "district_id"
    t.integer "grant_id"
  end

  create_table "grants", force: :cascade do |t|
    t.integer  "funder_id"
    t.integer  "recipient_id"
    t.string   "grant_identifier"
    t.string   "title"
    t.string   "description"
    t.string   "currency"
    t.string   "funding_programme"
    t.string   "gender"
    t.decimal  "amount_awarded"
    t.decimal  "amount_applied_for"
    t.decimal  "amount_disbursed"
    t.date     "award_date"
    t.date     "planned_start_date"
    t.date     "planned_end_date"
    t.boolean  "open_call"
    t.boolean  "affect_people"
    t.boolean  "affect_other"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "grants", ["funder_id"], name: "index_grants_on_funder_id", using: :btree
  add_index "grants", ["grant_identifier"], name: "index_grants_on_grant_identifier", using: :btree
  add_index "grants", ["recipient_id"], name: "index_grants_on_recipient_id", using: :btree

  create_table "organisations", force: :cascade do |t|
    t.integer  "country_id"
    t.string   "organisation_identifier"
    t.string   "slug"
    t.string   "name"
    t.string   "charity_number"
    t.string   "company_number"
    t.string   "street_address"
    t.string   "city"
    t.string   "region"
    t.string   "postal_code"
    t.string   "website"
    t.string   "registered_name"
    t.string   "company_type"
    t.integer  "org_type"
    t.integer  "operating_for"
    t.integer  "income"
    t.integer  "spending"
    t.integer  "employees"
    t.integer  "volunteers"
    t.boolean  "publisher"
    t.boolean  "multi_national"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "organisations", ["country_id"], name: "index_organisations_on_country_id", using: :btree
  add_index "organisations", ["organisation_identifier"], name: "index_organisations_on_organisation_identifier", using: :btree
  add_index "organisations", ["slug"], name: "index_organisations_on_slug", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
