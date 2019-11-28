# seeds.rbでロードするcsvファイルを生成する
# 列車時刻表で使う(６社しかない) → stationsから、乗換可能な列車の事業者一覧
operators_rw_ttt = [
  "odpt.Operator:JR-East",
  "odpt.Operator:TokyoMetro",
  "odpt.Operator:Toei",
  "odpt.Operator:TWR",
  "odpt.Operator:Keio",
  "odpt.Operator:YokohamaMunicipal",
]
#駅時刻表 / 路線情報 で使う(13社) → stations railways
operators_rw = operators_rw_ttt + [
  "odpt.Operator:Odakyu",
  "odpt.Operator:Keikyu",
  "odpt.Operator:Keisei",
  "odpt.Operator:Seibu",
  "odpt.Operator:Tokyu",
  "odpt.Operator:Tobu",
  "odpt.Operator:Yurikamome",
]

# 路線一覧を出す
railways = []
# 駅一覧を出す
stations = []

# 路線取得
operators_rw.each do |operator|
  Odpt::RailwayAPI.fetch({ "odpt:operator": operator }).each do |train|
    railway = [train["owl:sameAs"], train["odpt:operator"], 0]
    railways << railway
  end
end
#路線にid付与(手動で)
railways.each_with_index do |railway, i|
  railway.unshift(i + 1)
end
#路線が順番に並んだだけの配列 (id = index + 1)
rw_id = []
railways.each do |railway|
  rw_id << railway[1]
end

# 駅取得
operators_rw.each do |operator|
  Odpt::StationAPI.fetch({ "odpt:operator": operator }).each do |station|
    # result << station
    stations << [station["odpt:railway"], station["dc:title"], station["owl:sameAs"], station["geo:lat"], station["geo:long"]]
  end
end
# 駅テーブルの路線名columnをrailway_idに変換してintで格納
# 駅テーブルの中から、[railway_id=1の路線の総駅数、=2の総駅数,,]の配列作成 (railway_id-1番目の値に1を足していく)
station_num = Array.new(railways.length, 0)
stations.each do |station|
  station[0] = rw_id.index(station[0]) + 1
  station_num[station[0] - 1] += 1
end

# 路線テーブルのstation_numをstationテーブルで数えて更新
railways.each_with_index do |railway, i|
  railway[3] = station_num[i]
end

# ファイルに書き込む
CSV.open("result_rw.csv", mode = "w") do |f|
  railways.each do |r|
    f << [r[1], r[2], r[3]] # 最初のrailway_id は、idになるので消す
  end
end

CSV.open("result_st.csv", mode = "w") do |f|
  stations.each do |s|
    f << s
  end
end

# result = TrainTimetableAPI.fetch({ 'odpt:trainNumber': "1341F" })[0]["odpt:trainTimetableObject"]
# result = StationAPI.fetch({ 'odpt:operator': "odpt.Operator:JR-East" })[120]
