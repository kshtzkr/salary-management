class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.references :actor, foreign_key: { to_table: :users }, null: true
      t.string :action, null: false
      t.string :subject_type, null: false
      t.bigint :subject_id, null: false
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :audit_logs, %i[subject_type subject_id]
    add_index :audit_logs, :action
  end
end
