ActiveRecord::Schema[7.1].define(version: 2026_04_16_060100) do
  create_table "employees", force: :cascade do |t|
    t.string "employee_code", null: false
    t.string "full_name", null: false
    t.string "work_email", null: false
    t.string "job_title", null: false
    t.string "department", null: false
    t.string "country_code", null: false
    t.string "currency_code", null: false
    t.integer "annual_salary_cents", null: false
    t.date "hired_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 3, null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end
end
