class CreateRailways < ActiveRecord::Migration[5.2]
  def change
    create_table :railways do |t|
      t.string :jname, null: false
      t.string :name, null: false
      t.string :operator, null: false
      t.integer :station_num, null: false
      t.timestamps
    end
  end
end
