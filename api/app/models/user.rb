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

  def role_in?(roles)
    roles.map(&:to_s).include?(role)
  end

  def can_view_employees?
    role_in?(%i[admin hr_manager viewer])
  end

  def can_manage_employees?
    role_in?(%i[admin hr_manager])
  end

  def can_view_insights?
    role_in?(%i[admin hr_manager analyst])
  end

  def can_manage_users?
    admin?
  end
end
