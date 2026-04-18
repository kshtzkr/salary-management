class AddDeletedAtToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :deleted_at, :datetime unless column_exists?(:employees, :deleted_at)
    add_index  :employees, :deleted_at unless index_exists?(:employees, :deleted_at)
  end
end
