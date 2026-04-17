class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string  :employee_code, null: false
      t.string  :full_name, null: false
      t.string  :work_email, null: false
      t.string  :job_title, null: false
      t.string  :department, null: false
      t.string  :country_code, null: false
      t.string  :currency_code, null: false
      t.integer :annual_salary_cents, null: false
      t.date    :hired_on, null: false

      t.timestamps
    end

    add_index :employees, :employee_code, unique: true
    add_index :employees, :work_email, unique: true
  end
end
