ActiveRecord::Schema[7.1].define(version: 2026_04_16_060500) do
  create_table "audit_logs", force: :cascade do |t|
    t.integer "actor_id"
    t.string "action", null: false
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.json "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["subject_type", "subject_id"], name: "index_audit_logs_on_subject_type_and_subject_id"
  end

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
    t.integer "employment_status", default: 0, null: false
    t.datetime "deleted_at"
    t.boolean "synthetic", default: false, null: false
    t.index ["deleted_at"], name: "index_employees_on_deleted_at"
    t.index ["employee_code"], name: "index_employees_on_employee_code", unique: true
    t.index ["employment_status"], name: "index_employees_on_employment_status"
    t.index ["synthetic"], name: "index_employees_on_synthetic"
    t.index ["work_email"], name: "index_employees_on_work_email", unique: true
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

  add_foreign_key "audit_logs", "users", column: "actor_id"
end
