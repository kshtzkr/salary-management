class User < ApplicationRecord
  has_secure_password

  ROLES = {
    admin: 0,
    hr_manager: 1,
    analyst: 2,
    viewer: 3
  }.freeze

  enum role: ROLES

  normalizes :email, with: ->(value) { value.to_s.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true
  validates :role, presence: true
  validates :password, length: { minimum: 10 }, allow_nil: true
end
