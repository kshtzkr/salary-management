seed_password = ENV.fetch("DEMO_PASSWORD", "Password123!")

[
  ["Admin User", "admin@salary.local", :admin],
  ["HR Manager", "hr@salary.local", :hr_manager],
  ["Analyst User", "analyst@salary.local", :analyst],
  ["Viewer User", "viewer@salary.local", :viewer]
].each do |full_name, email, role|
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    full_name: full_name,
    role: role,
    active: true,
    password: seed_password,
    password_confirmation: seed_password
  )
  user.save!
end

first_names = Rails.root.join("db/seeds/first_names.txt").read.lines.map(&:strip).reject(&:blank?).freeze
last_names  = Rails.root.join("db/seeds/last_names.txt").read.lines.map(&:strip).reject(&:blank?).freeze
random      = Random.new(20_260_416)

countries = [
  { code: "US", currency: "USD" },
  { code: "IN", currency: "INR" },
  { code: "GB", currency: "GBP" },
  { code: "AE", currency: "AED" },
  { code: "SG", currency: "SGD" }
].freeze

job_titles = [
  "Software Engineer",
  "Senior Software Engineer",
  "Engineering Manager",
  "Product Manager",
  "HR Business Partner",
  "Data Analyst",
  "Finance Manager",
  "Customer Success Manager",
  "Sales Manager",
  "Marketing Lead"
].freeze

departments = [
  "Engineering",
  "Product",
  "Human Resources",
  "Finance",
  "Sales",
  "Marketing",
  "Operations",
  "Customer Success"
].freeze

statuses   = %w[active active active active probation leave_of_absence inactive].freeze
batch_size = 1_000
rows       = []

Employee.transaction do
  Employee.where(synthetic: true).delete_all

  10_000.times do |index|
    country    = countries[random.rand(countries.length)]
    first_name = first_names[random.rand(first_names.length)]
    last_name  = last_names[random.rand(last_names.length)]

    rows << {
      employee_code: format("EMP-%05d", index + 1),
      full_name: "#{first_name} #{last_name}",
      work_email: "#{first_name.downcase}.#{last_name.downcase}.#{index + 1}@employees.salary.local",
      job_title: job_titles[random.rand(job_titles.length)],
      department: departments[random.rand(departments.length)],
      country_code: country[:code],
      currency_code: country[:currency],
      annual_salary_cents: random.rand(45_000_00..280_000_00),
      employment_status: Employee.employment_statuses.fetch(statuses[random.rand(statuses.length)]),
      hired_on: Date.new(2019, 1, 1) + random.rand(2_400),
      synthetic: true,
      created_at: Time.current,
      updated_at: Time.current
    }

    if rows.length >= batch_size
      Employee.insert_all!(rows)
      rows = []
    end
  end

  Employee.insert_all!(rows) if rows.any?
end
