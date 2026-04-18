class AddSyntheticToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :synthetic, :boolean, null: false, default: false unless column_exists?(:employees, :synthetic)
    add_index  :employees, :synthetic unless index_exists?(:employees, :synthetic)
  end
end
