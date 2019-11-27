class CreatePassedRailways < ActiveRecord::Migration[5.2]
  def change
    create_table :passed_railways do |t|
      t.references :avatar, foreign_key: true
      t.references :railway, foreign_key: true

      t.timestamps
    end
  end
end
