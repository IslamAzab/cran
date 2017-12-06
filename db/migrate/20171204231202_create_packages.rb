class CreatePackages < ActiveRecord::Migration[5.1]
  def change
    create_table :packages do |t|
      t.string :name
      t.string :version
      t.datetime :date_publication
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
