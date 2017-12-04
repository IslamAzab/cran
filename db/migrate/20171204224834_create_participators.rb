class CreateParticipators < ActiveRecord::Migration[5.1]
  def change
    create_table :participators do |t|
      t.string :name
      t.string :email
      t.integer :role

      t.timestamps
    end
  end
end
