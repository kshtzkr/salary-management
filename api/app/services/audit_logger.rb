class AuditLogger
  def self.log!(actor:, action:, subject:, changeset: nil)
    AuditLog.create!(
      actor: actor,
      action: action,
      subject_type: subject.class.name,
      subject_id: subject.id,
      metadata: changeset || {}
    )
  end
end
