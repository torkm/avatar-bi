class CreatePassedStations < ActiveRecord::Migration[5.2]
  def change
    create_table :passed_stations do |t|
      t.references :avatar, foreign_key: true
      t.references :station, foreign_key: true
      t.boolean :has_passed, default: false, null: false
      t.time :passed_at

      t.timestamps
    end
  end
end
