class Employee < ApplicationRecord
  validates :employee_code, :full_name, :work_email, :job_title, :department, :country_code, :currency_code, :hired_on, presence: true
  validates :annual_salary_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
end
