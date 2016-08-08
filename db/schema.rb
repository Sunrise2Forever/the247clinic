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

ActiveRecord::Schema.define(version: 20160709033703) do

  create_table "answers", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "message"
    t.integer  "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "appointments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "clinic_id"
    t.integer  "doctor_id"
    t.string   "email"
    t.string   "phone"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "user_name"
  end

  create_table "call_backs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "doctor_id"
    t.datetime "scheduled_time"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "clinics", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "not_opening_days"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "favorite_clinics", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "clinic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "favorite_doctors", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "doctor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "status"
  end

  create_table "not_working_dates", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "online_visits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "csr_id"
    t.datetime "scheduled_time"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "opentok_sessions", force: :cascade do |t|
    t.integer  "video_session_id"
    t.string   "session_id"
    t.string   "token"
    t.string   "e"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "opentok_sessions", ["video_session_id"], name: "index_opentok_sessions_on_video_session_id"

  create_table "photos", force: :cascade do |t|
    t.integer  "video_session_id"
    t.string   "photo_url"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "doctor_id"
    t.string   "title"
    t.string   "details"
    t.boolean  "done"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "mspnum"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "activation_digest"
    t.boolean  "activated",            default: false
    t.datetime "activated_at"
    t.boolean  "admin",                default: false
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "country"
    t.string   "provincestate"
    t.string   "zipcode"
    t.string   "phone"
    t.string   "gender"
    t.date     "birthdate"
    t.string   "user_type"
    t.integer  "clinic_id"
    t.string   "not_working_days"
    t.string   "authentication_token"
    t.string   "presence_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token"

  create_table "video_sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "symptom"
    t.datetime "start_time"
    t.datetime "finish_time"
    t.text     "feedback"
    t.text     "notes"
    t.integer  "doctor_id"
    t.string   "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "call_back_id"
    t.boolean  "sign_off"
    t.string   "diagnosis"
  end

  create_table "working_schedules", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "scheduled_day_of_week"
    t.date     "scheduled_date"
    t.time     "start_time"
    t.time     "end_time"
    t.boolean  "weekly"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "working_schedules", ["user_id"], name: "index_working_schedules_on_user_id"

end
