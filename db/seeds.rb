# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require "csv"
#csvファイルを扱うためのgemを読み込む

CSV.foreach("db/result_rw.csv") do |row|
  #foreachは、ファイル（hoge.csv）の各行を引数として、ブロック(do~endまでを範囲とする『引数のかたまり』)を繰り返し実行する
  #rowには、読み込まれた行が代入される
  Railway.create(jname: row[0], name: row[1], operator: row[2], station_num: row[3])
  #usersテーブルの各カラムに、各行のn番目の値を代入している。
end

CSV.foreach("db/result_st.csv") do |row|
  Station.create(railway_id: row[0], name: row[1], odpt_sameAs: row[2], lat: row[3], long: row[4])
end
