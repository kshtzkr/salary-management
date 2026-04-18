class AddSyntheticToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :synthetic, :boolean, null: false, default: false
    add_index  :employees, :synthetic
  end
end
