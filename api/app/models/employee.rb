class Employee < ApplicationRecord
  normalizes :country_code, with: ->(value) { value.to_s.upcase }
  normalizes :currency_code, with: ->(value) { value.to_s.upcase }
  normalizes :work_email, with: ->(value) { value.to_s.strip.downcase }

  validates :employee_code, :full_name, :work_email, :job_title, :department, :country_code, :currency_code, :hired_on, presence: true
  validates :annual_salary_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :employee_code, :work_email, uniqueness: true
  validates :country_code, length: { is: 2 }
  validates :currency_code, length: { is: 3 }
end
