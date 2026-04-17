class User < ApplicationRecord
  normalizes :email, with: ->(value) { value.to_s.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
