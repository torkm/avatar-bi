class CreateStations < ActiveRecord::Migration[5.2]
  def change
    create_table :stations do |t|
      t.references :railway, foreign_key: true
      t.string :name, null: false
      t.integer :odpt_sameAs, null: false, index: true
      t.float :lat, null: false
      t.float :long, null: false

      t.timestamps
    end
  end
end
