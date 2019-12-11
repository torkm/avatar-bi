class AddRefToAvatars < ActiveRecord::Migration[5.2]
  def change
    change_column :avatars, :curr_station_id, :bigint
    change_column :avatars, :last_station_id, :bigint
    change_column :avatars, :home_station_id, :bigint
    add_foreign_key :avatars, :stations, column: :curr_station_id
    add_foreign_key :avatars, :stations, column: :last_station_id
    add_foreign_key :avatars, :stations, column: :home_station_id
  end
end
