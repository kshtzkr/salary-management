class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true

  validates :action, :subject_type, :subject_id, presence: true
end
