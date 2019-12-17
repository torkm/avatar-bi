# seeds.rbでロードするcsvファイルを生成する
#ruby odpt_seed.rb で生成したcsvファイルをseed.rbディレクトリに移動してrails db:seed
require "faraday"
require "json"
require "csv"

class TrainAPI
  BASE_URL = "https://api-tokyochallenge.odpt.org/api/v4/odpt:"
  CONSUMER_KEY = "25a4a87678a6bd930c91bf66fff22bea5204a90c6ed59605e9ccc65cfb7c0fb3"

  def self.make_get_request(path, params)
    url = BASE_URL + path
    conn = Faraday.new(url)
    res = conn.get do |req|
      req.params["acl:consumerKey"] = CONSUMER_KEY
      params.each do |key, value|
        req.params[key] = value
      end
    end
    return JSON.parse(res.body)
  end
end

class StationAPI < TrainAPI
  PATH = "Station"

  def self.fetch(params)
    make_get_request(PATH, params)
  end
end

class TrainTimetableAPI < TrainAPI
  PATH = "TrainTimetable"

  def self.fetch(params)
    make_get_request(PATH, params)
  end
end

class StationTimetableAPI < TrainAPI
  PATH = "StationTimetable"

  def self.fetch(params)
    make_get_request(PATH, params)
  end
end

class RailwayAPI < TrainAPI
  PATH = "Railway"

  def self.fetch(params)
    make_get_request(PATH, params)
  end
end

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
  RailwayAPI.fetch({ "odpt:operator": operator }).each do |train|
    railway = [train["dc:title"], train["owl:sameAs"], train["odpt:operator"], 0]
    railways << railway
  end
end
#路線にid付与(1から始まる、unshiftで先頭に)
#路線テーブルに、has_TrainTimetable付与(持っていればtrue,持っていなければfalse)
#末尾にpushでつける
railways.each_with_index do |railway, i|
  railway.unshift(i + 1)
  if [13, 14, 18, 21,22, 23, 25, 26, 30,  32,33,34, 35, 38, 39,  43, 44,45,46, 49,  53, 54, 60, 61, 63, 67, 69, 72, 75, 76, 77,80,  82, 83, 84,85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110].include?(i + 1)
    has_TrainTimetable = true
  else
    has_TrainTimetable = false
  end
  # puts has_TrainTimetable
  railway.push(has_TrainTimetable)
end
puts railways
CSV.open("rw.csv", mode = "w") do |f|
  f << railways
end

#路線が順番に並んだだけの配列 (id = index + 1　, owl:sameAs)
rw_id = []
railways.each do |railway|
  rw_id << railway[2]
end

# 駅取得
operators_rw.each do |operator|
  StationAPI.fetch({ "odpt:operator": operator }).each do |station|
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
  railway[4] = station_num[i]
end

# ファイルに書き込む
CSV.open("result_rw.csv", mode = "w") do |f|
  railways.each do |r|
    f << [r[1], r[2], r[3], r[4], r[5]] # 最初のrailway_id は、idになるので消す
  end
end

CSV.open("result_st.csv", mode = "w") do |f|
  stations.each do |s|
    f << s
  end
end

# result = TrainTimetableAPI.fetch({ 'odpt:trainNumber': "1341F" })[0]["odpt:trainTimetableObject"]
# result = StationAPI.fetch({ 'odpt:operator': "odpt.Operator:JR-East" })[120]
