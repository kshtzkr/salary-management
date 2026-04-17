class Employee < ApplicationRecord
  EMPLOYMENT_STATUSES = {
    active: 0,
    probation: 1,
    leave_of_absence: 2,
    inactive: 3
  }.freeze

  enum employment_status: EMPLOYMENT_STATUSES

  scope :kept,     -> { where(deleted_at: nil) }
  scope :archived, -> { where.not(deleted_at: nil) }

  normalizes :country_code, with: ->(value) { value.to_s.upcase }
  normalizes :currency_code, with: ->(value) { value.to_s.upcase }
  normalizes :work_email, with: ->(value) { value.to_s.strip.downcase }

  validates :employee_code, :full_name, :work_email, :job_title, :department, :country_code, :currency_code, :hired_on, presence: true
  validates :annual_salary_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :employee_code, :work_email, uniqueness: true
  validates :country_code, length: { is: 2 }
  validates :currency_code, length: { is: 3 }
end
