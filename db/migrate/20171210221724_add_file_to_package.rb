class AddFileToPackage < ActiveRecord::Migration[5.1]
  def change
    add_column :packages, :file_name, :string
    add_column :packages, :file_content, :binary, limit: 20.megabyte
  end
end
