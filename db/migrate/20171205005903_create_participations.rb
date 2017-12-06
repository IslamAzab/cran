class CreateParticipations < ActiveRecord::Migration[5.1]
  def change
    create_table :participations do |t|
      t.references :package, foreign_key: true
      t.references :participant, foreign_key: true
      t.integer :role

      t.timestamps
    end
  end
end
