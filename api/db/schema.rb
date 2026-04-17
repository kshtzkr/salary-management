ActiveRecord::Schema[7.1].define(version: 2026_04_16_060000) do
  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
