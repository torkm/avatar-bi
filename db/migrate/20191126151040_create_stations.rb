class CreateStations < ActiveRecord::Migration[5.2]
  def change
    create_table :stations do |t|
      t.references :railway, foreign_key: true
      t.string :name, null: false
      t.integer :station_code, null: false
      t.float :lat, null: false
      t.float :long, null: false

      t.timestamps
    end
  end
end
