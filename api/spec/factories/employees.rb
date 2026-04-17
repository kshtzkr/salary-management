FactoryBot.define do
  factory :employee do
    sequence(:employee_code) { |n| format("EMP-%04d", n) }
    sequence(:work_email)    { |n| "employee#{n}@salary.local" }
    full_name           { "Test Employee" }
    job_title           { "Engineer" }
    department          { "Engineering" }
    country_code        { "US" }
    currency_code       { "USD" }
    annual_salary_cents { 100_000_00 }
    employment_status   { :active }
    hired_on            { Date.new(2024, 1, 1) }
  end
end
