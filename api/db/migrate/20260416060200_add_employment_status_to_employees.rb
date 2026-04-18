class AddEmploymentStatusToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :employment_status, :integer, null: false, default: 0 unless column_exists?(:employees, :employment_status)
    add_index  :employees, :employment_status unless index_exists?(:employees, :employment_status)
  end
end
