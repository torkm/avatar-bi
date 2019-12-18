class Travel
  #文字列をtime型に変換する関数
  def self.to_time(time)
    unless time.kind_of?(Time)
      time = Time.parse(time)
    end
    # time = time.at(t.to_i / 60 * 60)
    return time
  end

  #距離判定 kmで返す
  def self.distance(lat1, lng1, lat2, lng2)
    x1 = lat1.to_f * Math::PI / 180
    y1 = lng1.to_f * Math::PI / 180
    x2 = lat2.to_f * Math::PI / 180
    y2 = lng2.to_f * Math::PI / 180
    radius = 6378.137
    diff_y = (y1 - y2).abs
    calc1 = Math.cos(x2) * Math.sin(diff_y)
    calc2 = Math.cos(x1) * Math.sin(x2) - Math.sin(x1) * Math.cos(x2) * Math.cos(diff_y)
    numerator = Math.sqrt(calc1 ** 2 + calc2 ** 2)
    denominator = Math.sin(x1) * Math.sin(x2) + Math.cos(x1) * Math.cos(x2) * Math.cos(diff_y)
    degree = Math.atan2(numerator, denominator)
    degree * radius
  end

  #方角判定 pos1[lat, long]からpos2[lat, long]への方角 0-360
  def self.azimuth(x1, y1, x2, y2)
    # Radian角に修正
    pi = Math::PI
    x1, y1, x2, y2 = x1 * pi / 180, y1 * pi / 180, x2 * pi / 180, y2 * pi / 180
    delta_x = x2 - x1
    y = Math.sin(delta_x)
    x = Math.cos(y1) * Math.tan(y2) - Math.sin(y1) * Math.cos(delta_x)

    psi = Math.atan2(y, x) * 180 / pi
    if psi < 90
      return 360 + Math.atan2(y, x) * 180 / pi - 90
    else
      return Math.atan2(y, x) * 180 / pi - 90
    end
  end

  # 次の電車の路線名を決定
  def self.getNextRailway(station)
    #入力はlast_stationのid (現在時刻は関数内で使用)
    #①乗換可能な路線一覧をStationAPIで抽出（含 アバタの現在路線）
    result = Odpt::StationAPI.fetch({ "owl:sameAs": station.odpt_sameAs })
    candidates = [result[0]["odpt:railway"]]
    if result[0]["odpt:connectingRailway"]
      candidates += result[0]["odpt:connectingRailway"]
    end
      possible_railways = []

    # railwayテーブルに登録されていて、かつ TrainTimetableを持っている路線だけ選抜
    candidates.each do |candidate|
      if Railway.find_by(name: candidate)
        if Railway.find_by(name: candidate).has_TrainTimetable
          possible_railways << candidate
        end
      end
    end

    # puts "選択肢は", possible_railways

    #②列車時刻表の提供されている路線から一つを選択(railwayテーブル)
    next_railway = possible_railways.sample #まだ適当

    # puts "乗る路線は", next_railway
    return next_railway
  end

  # その路線での出発駅を指定(最も近いところ)
  def self.getDepartureStation(station, next_railway)
    #ToDo ②.5 何駅から乗るかを座標で決める（入力駅から最も近いとこ）
    here = [station.lat, station.long]
    next_railway_id = Railway.find_by(name: next_railway).id
    stations = Station.where(railway_id: next_railway_id)
    candidates = []
    distances = []
    #next_railwayの [駅id, 緯度、経度]を収納
    stations.each do |station|
      candidates << [station.odpt_sameAs, station.lat, station.long]
    end
    candidates.each do |c|
      distances << distance(here[0], here[1], c[1], c[2])
    end

    dep_station = candidates[distances.index(distances.min)][0]

    # puts "出発駅は", dep_station
    return dep_station
  end

  # 乗る列番を決定
  def self.getTrainNumber(dep_station, time)
    #③StationTimetableAPIで次乗る路線の駅時刻表ゲット

      result = time.workday? ? 
      Odpt::StationTimetableAPI.fetch({ "odpt:station": dep_station, "odpt:calendar": "odpt.Calendar:Weekday" }) : 
      Odpt::StationTimetableAPI.fetch({ "odpt:station": dep_station, "odpt:calendar": "odpt.Calendar:SaturdayHoliday" })
    
    
    #④-1[列番,時刻]の二次元配列を作成し、早い順にソート
    time_numbers = []
    result.each do |r| # 列車一つずつ取り出して、↓で時刻と列番だけ抽出
      r["odpt:stationTimetableObject"].each do |train|
        time_numbers << [train["odpt:trainNumber"], train["odpt:departureTime"]]
      end
      time_numbers = time_numbers.sort_by { |_, b| b }
    end

    #④-2現在時刻に最も近い列番を抽出
    train_number = []
    time_numbers.each do |time_number|
      #時刻表時刻が現在時刻を超えたときの列番を記録
      if time < Time.parse(time_number[1])
        train_number = time_number[0]
        break
      end
      # もしその日付内になければ(23:58など)、翌日の始発を選択
      # train_number = time_numbers[0][0]
    end

    puts "乗る列番は", train_number
    return train_number
  end

  # 列番の時刻表を作成
  def self.getTrainTimetable(dep_station, next_railway, train_number,time)
    ########    列番と路線名指定と出発駅が指定できた後、その時刻表(出発駅以降)を作成  ####################
    #①指定した路線名、平/休日、列番の列車
    w_or_h = time.workday? ? "odpt.Calendar:Weekday" : "odpt.Calendar:SaturdayHoliday"
    params = {
      "odpt:railway": next_railway,
      'odpt:calendar': w_or_h,
      'odpt:trainNumber': train_number,
    }

    result = Odpt::TrainTimetableAPI.fetch(params)[0]["odpt:trainTimetableObject"]

    #② 出発駅、時刻を記録(なければ到着駅、時刻)
    train_timetable = []
    result.each do |r|
      if r.has_key?("odpt:departureTime")
        train_timetable << [r["odpt:departureStation"], r["odpt:departureTime"]]
      else
        train_timetable << [r["odpt:arrivalStation"], r["odpt:arrivalTime"]]
      end
    end

    #③出発駅以降の時刻表だけ残す  一致するまでtraintimetable削除
    while true
      if train_timetable[0][0] == dep_station
        break
      else
        train_timetable.shift
      end
    end

    #④時分がnilのことがあるので、その駅以降はすべて削除
    train_timetable.each_with_index do |t, i|
      if t[1].nil?
        train_timetable.slice!(i..train_timetable.length)
        break
      end
    end
    return train_timetable
  end

  ####################################################
  # メイン関数A 上記に加え,DB操作が加わっている
  # アバター名を入力し、入力した時刻以降で、次に乗る列車(路線はランダム)の時刻表と出発駅を配列で出力
  def self.getCurrentTrainTimetable(station, time)
    # 時刻がstr型なら、time型に変換する。
    time = to_time(time)
    # ①次に乗る線名を決める
    next_railway = getNextRailway(station)
    # ②何線の何駅から乗るかを決める(入力路線で、入力駅か��最も近い駅)
    dep_station = getDepartureStation(station, next_railway)
    # ③入力した時刻以降で次に乗れる電車の列番決定
    train_number = getTrainNumber(dep_station, time)
    # ④指定した列番の時刻表生成 ([駅名,出発時刻])
    train_timetable = getTrainTimetable(dep_station, next_railway, train_number,time)
    puts train_timetable
    return train_timetable
  end

  # メイン関数B
  # 入力時刻の列車現在位置の取得 (駅は最後に到達した駅、座標は２駅の間を計算して取得)
  # [最近通過した駅名、次の駅名、現在lat, 現在long, 方向(°)]
  def self.getTrainPosition(train_timetable, time)
    # timeがstr
    time = to_time(time)

    position = []
    train_timetable.each_with_index do |train_time, i|
      #現在時刻が、ある駅の到着予定時刻を下回ったら、その一個前の駅まで到着しているとして記録 ただし出発駅のままの場合は一個前ではなくその駅
      if time < Time.parse(train_time[1])
        #スタートから一駅も動いていない場合は例外的にcurr設定
        curr_station = Station.find_by(odpt_sameAs: train_timetable[[0, i - 1].max][0])
        next_station = Station.find_by(odpt_sameAs: train_timetable[[1, i].max][0])
        lat_c = curr_station.lat
        lat_n = next_station.lat
        long_c = curr_station.long
        long_n = next_station.long

        if i == 0
          lat = curr_station.lat
          long = curr_station.long
        else #座標は現在駅と次駅の座標の加重平均を取る
          time_c = to_time(train_timetable[i - 1][1])
          time_n = to_time(train_timetable[i][1])

          lat = (lat_c * (time - time_n).abs + lat_n * (time - time_c).abs) / (time_c - time_n).abs
          long = (long_c * (time - time_n).abs + long_n * (time - time_c).abs) / (time_c - time_n).abs
        end

        position = [curr_station.id, next_station.id, lat, long, azimuth(lat_c, long_c, lat_n, long_n)]
        break
      end
    end
    #最後まで時間が下回らない(=終点まで行った)なら、最後の駅
    if position == []
      curr_station = Station.find_by(odpt_sameAs: train_timetable[-1][0])
      puts curr_station.odpt_sameAs
      position = [curr_station.id, curr_station.id, curr_station.lat, curr_station.long, 0]
    end
    return position
  end

  ########################################################
end

