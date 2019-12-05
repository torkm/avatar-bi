class ChangeDatatypeHasPassedOfPassedStations < ActiveRecord::Migration[5.2]
  def change
    # [形式] change_column(テーブル名, カラム名, データタイプ, オプション)
    change_column :passed_stations, :has_passed, :integer, default: 0
  end
end
