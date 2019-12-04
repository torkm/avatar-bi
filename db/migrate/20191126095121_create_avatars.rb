class CreateAvatars < ActiveRecord::Migration[5.2]
  def change
    create_table :avatars do |t|
      t.references :user, foreign_key: true
      t.string :name, null: false
      t.integer :avatar_type, null: false
      t.integer :stage, null: false
      t.integer :curr_station_id, null: false
      t.float :curr_location_lat
      t.float :curr_location_long
      t.integer :last_station_id, null: false
      t.float :last_location_lat
      t.float :last_location_long
      t.integer :home_station_id, null: false
      t.text :train_timetable
      t.timestamps
    end
  end
end
