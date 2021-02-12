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

ActiveRecord::Schema.define(version: 2021_02_12_145630) do

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "reader", null: false
    t.integer "university_id"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["university_id"], name: "index_admin_users_on_university_id"
  end

  create_table "auditoriums", force: :cascade do |t|
    t.string "name"
    t.integer "server_id"
    t.integer "university_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "slug_en"
    t.string "slug_uk"
    t.integer "building_id"
    t.string "lowercase_name"
    t.index ["building_id"], name: "index_auditoriums_on_building_id"
    t.index ["slug"], name: "index_auditoriums_on_slug", unique: true
    t.index ["slug_en"], name: "index_auditoriums_on_slug_en"
    t.index ["slug_uk"], name: "index_auditoriums_on_slug_uk"
    t.index ["university_id"], name: "index_auditoriums_on_university_id"
  end

  create_table "auditoriums_disciplines", id: false, force: :cascade do |t|
    t.integer "auditorium_id"
    t.integer "discipline_id"
    t.index ["auditorium_id"], name: "index_auditoriums_disciplines_on_auditorium_id"
    t.index ["discipline_id"], name: "index_auditoriums_disciplines_on_discipline_id"
  end

  create_table "buildings", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "university_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "server_id"
    t.string "slug"
    t.string "slug_en"
    t.string "slug_uk"
    t.index ["slug"], name: "index_buildings_on_slug"
    t.index ["slug_en"], name: "index_buildings_on_slug_en"
    t.index ["slug_uk"], name: "index_buildings_on_slug_uk"
    t.index ["university_id"], name: "index_buildings_on_university_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "server_id"
    t.integer "university_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "slug_en"
    t.string "slug_uk"
    t.index ["slug"], name: "index_departments_on_slug"
    t.index ["slug_en"], name: "index_departments_on_slug_en"
    t.index ["slug_uk"], name: "index_departments_on_slug_uk"
    t.index ["university_id"], name: "index_departments_on_university_id"
  end

  create_table "disciplines", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "university_id"
    t.index ["university_id"], name: "index_disciplines_on_university_id"
  end

  create_table "disciplines_groups", id: false, force: :cascade do |t|
    t.integer "discipline_id"
    t.integer "group_id"
    t.index ["discipline_id"], name: "index_disciplines_groups_on_discipline_id"
    t.index ["group_id"], name: "index_disciplines_groups_on_group_id"
  end

  create_table "disciplines_teachers", id: false, force: :cascade do |t|
    t.integer "discipline_id"
    t.integer "teacher_id"
    t.index ["discipline_id"], name: "index_disciplines_teachers_on_discipline_id"
    t.index ["teacher_id"], name: "index_disciplines_teachers_on_teacher_id"
  end

  create_table "faculties", force: :cascade do |t|
    t.string "name"
    t.integer "server_id"
    t.integer "university_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "slug_en"
    t.string "slug_uk"
    t.index ["slug"], name: "index_faculties_on_slug"
    t.index ["slug_en"], name: "index_faculties_on_slug_en"
    t.index ["slug_uk"], name: "index_faculties_on_slug_uk"
    t.index ["university_id"], name: "index_faculties_on_university_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.integer "server_id"
    t.integer "university_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "slug_en"
    t.string "slug_uk"
    t.string "lowercase_name"
    t.integer "faculty_id"
    t.integer "speciality_id"
    t.integer "course"
    t.integer "stream"
    t.index ["faculty_id"], name: "index_groups_on_faculty_id"
    t.index ["slug"], name: "index_groups_on_slug"
    t.index ["slug_en"], name: "index_groups_on_slug_en"
    t.index ["slug_uk"], name: "index_groups_on_slug_uk"
    t.index ["speciality_id"], name: "index_groups_on_speciality_id"
    t.index ["university_id"], name: "index_groups_on_university_id"
  end

  create_table "groups_records", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "record_id"
    t.index ["group_id"], name: "index_groups_records_on_group_id"
    t.index ["record_id"], name: "index_groups_records_on_record_id"
  end

  create_table "records", force: :cascade do |t|
    t.string "name"
    t.string "pair_name"
    t.string "reason"
    t.string "kind"
    t.string "time"
    t.integer "auditorium_id"
    t.integer "teacher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "university_id"
    t.datetime "pair_start_date"
    t.integer "discipline_id"
    t.index ["auditorium_id"], name: "index_records_on_auditorium_id"
    t.index ["discipline_id"], name: "index_records_on_discipline_id"
    t.index ["teacher_id"], name: "index_records_on_teacher_id"
    t.index ["university_id"], name: "index_records_on_university_id"
  end

  create_table "specialities", force: :cascade do |t|
    t.string "name"
    t.integer "server_id"
    t.integer "university_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "slug_en"
    t.string "slug_uk"
    t.index ["slug"], name: "index_specialities_on_slug"
    t.index ["slug_en"], name: "index_specialities_on_slug_en"
    t.index ["slug_uk"], name: "index_specialities_on_slug_uk"
    t.index ["university_id"], name: "index_specialities_on_university_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.string "name"
    t.integer "server_id"
    t.integer "university_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "slug_en"
    t.string "slug_uk"
    t.string "lowercase_name"
    t.integer "department_id"
    t.index ["department_id"], name: "index_teachers_on_department_id"
    t.index ["slug"], name: "index_teachers_on_slug", unique: true
    t.index ["slug_en"], name: "index_teachers_on_slug_en"
    t.index ["slug_uk"], name: "index_teachers_on_slug_uk"
    t.index ["university_id"], name: "index_teachers_on_university_id"
  end

  create_table "universities", force: :cascade do |t|
    t.string "short_name"
    t.string "full_name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_hidden", default: false
    t.boolean "is_beta", default: false
    t.string "website", default: ""
    t.integer "uid", default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
