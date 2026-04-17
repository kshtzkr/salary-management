class Employee < ApplicationRecord
  validates :employee_code, :full_name, :work_email, :job_title, :department, :country_code, :currency_code, :hired_on, presence: true
  validates :annual_salary_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :employee_code, :work_email, uniqueness: true
  validates :country_code, length: { is: 2 }
  validates :currency_code, length: { is: 3 }
end
