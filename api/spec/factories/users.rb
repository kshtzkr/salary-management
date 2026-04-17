FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@salary.local" }
    full_name { "Test User" }
    role { :viewer }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    active { true }
  end
end
