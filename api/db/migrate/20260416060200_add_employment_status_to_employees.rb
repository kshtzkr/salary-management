class AddEmploymentStatusToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :employment_status, :integer, null: false, default: 0
    add_index  :employees, :employment_status
  end
end
