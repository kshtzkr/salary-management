class Employee < ApplicationRecord
  validates :employee_code, :full_name, :work_email, :job_title, :department, :country_code, :currency_code, :hired_on, presence: true
end
