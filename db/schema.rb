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

ActiveRecord::Schema.define(version: 2018_12_27_171006) do

  create_table "auditoriums", force: :cascade do |t|
    t.string "name"
    t.integer "server_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.integer "server_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "records", force: :cascade do |t|
    t.datetime "start_date"
    t.string "name"
    t.string "pair_name"
    t.string "reason"
    t.string "type"
    t.string "time"
    t.integer "auditorium_id"
    t.integer "group_id"
    t.integer "teacher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auditorium_id"], name: "index_records_on_auditorium_id"
    t.index ["group_id"], name: "index_records_on_group_id"
    t.index ["teacher_id"], name: "index_records_on_teacher_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.string "name"
    t.integer "server_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
