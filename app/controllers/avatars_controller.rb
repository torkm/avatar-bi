require "time"
require "csv"

class AvatarsController < ApplicationController
  protect_from_forgery except: :create

  def new
    unless current_user.avatars[0] == nil
      redirect_to root_path, notice: "すでにアバターを持っています"
      return
    else
      @avatar = Avatar.new
    end
  end
  
  def create
    @avatar = Avatar.new(avatar_params)
    if @avatar.save
      # 拠点駅に選んだ駅を、passed_stationに登録
      PassedStation.create(avatar_id: @avatar.id, station_id: @avatar.curr_station_id)

      # アバター作成時、csvを作成
      sta = Station.find(@avatar.home_station_id)
      empty_timetable = ""
      CSV.open("db/csv/#{@avatar.id}_curr.csv", "w") do |content|
        content << [sta.id, sta.odpt_sameAs, sta.name, sta.railway.jname, sta.lat, sta.long, sta.id, sta.name, 0, empty_timetable]
      end
      CSV.open("db/csv/#{@avatar.id}_path.csv", "w") do |content|
        content << [Station.find(@avatar.curr_station_id).lat, Station.find(@avatar.curr_station_id).long]
      end

      redirect_to root_path, notice: "アバターを登録しました"
    else
      render :new
      return
    end
  end

  def travel

    #############  これを一定時間でループ   #############
    @avatar = current_user.avatars[0]
    starting_id = @avatar.curr_station_id

    @station = Station.find(starting_id)
    @train_timetable = eval(@avatar.train_timetable) #avatarから呼び出し、配列に変換
    @time = Time.now
    unless @train_timetable # avatarが時刻表持っていない場合(= 旅行開始時、終点に着いて次の移動)
      @train_timetable = Travel.getCurrentTrainTimetable(@station, @time)  #Aで時刻表ゲット
    end
    @position = Travel.getTrainPosition(@train_timetable, @time) #Bで現在地更新
    # ② 終点についていたらtrain_timetable 削除
    if Station.find(@position[0]).odpt_sameAs == @train_timetable[-1][0] #終点についていたら削除
      @train_timetable = ""
    end

    # ③-1  DB操作 (avatar)
    @avatar.train_timetable = @train_timetable.to_s # 文字列にして時刻表更新
    @avatar.curr_station_id = @position[0]
    @avatar.curr_location_lat = @position[2]
    @avatar.curr_location_long = @position[3]
    # curr_locationはユーザー詳細ページで使用
    @avatar.save

    #③-2  DB操作 (passed_station): current駅が変わっていたら、
    #・[avatar_id, 通過駅_id]の組み合わせをpassed_stationに保存
    # ・最新駅一個手前の駅までの、今回の移動で行った駅の座標csvに保存
    unless starting_id == @position[0]
      # すでに一度訪れているなら、レコード利用 / なかったら、新規作成
      if @avatar.passed_stations.find_by(station_id: @position[0])
        @passed_station = @avatar.passed_stations.find_by(station_id: @position[0])
        @passed_station.has_passed += 1
        @passed_station.passed_at = @time
      else
        @passed_station = PassedStation.new(avatar_id: @avatar.id, station_id: @position[0], has_passed: 1, passed_at: @time)
      end
      @passed_station.save
      # 現在駅が更新されるごとに、id_path.csvファイルに最新の駅座標を格納
      CSV.open("db/csv/#{@avatar.id}_path.csv", "a") do |content|
        content << [Station.find(@position[0]).lat, Station.find(@position[0]).long]
      end
    end
    # ④ 現在位置などはcsvに保存
    # 現在駅id, 現在駅sameAs, 現在駅名, 現在路線,　現在lat, 現在long, 次駅id, 次駅名, 進行方向の角度, 現在時刻表
    sta = Station.find(@position[0])
    n_sta = Station.find(@position[1])
    CSV.open("db/csv/#{@avatar.id}_curr.csv", "w") do |content|
      content << [sta.id, sta.odpt_sameAs, sta.name, sta.railway.jname, @position[2], @position[3], n_sta.id, n_sta.name, @position[4], @train_timetable]
    end

    ###############################################
  end

  def reload
    # avatar複数の時は行をループ
    # values = CSV.read("db/csv/#{current_user.id}_curr.csv")[0]
    avatar = current_user.avatars[0]
    values = CSV.read("db/csv/#{avatar.id}_curr.csv")[0]
    if File.exist?("db/csv/#{avatar.id}_path.csv")
      path = CSV.read("db/csv/#{avatar.id}_path.csv")
      path = path.map { |path| path.map { |path| path.to_f } }
      path << [values[4], values[5]] #現在の座標追加
    else
      path = [values[4], values[5]] #現在の座標追加
    end
    values << path.to_s
    # csvの中身をhashに変換
    keys = ["sta_id", "sta_sameAs", "sta_name", "railway", "curr_lat", "curr_long", "n_sta_id", "n_sta_name", "viewangle", "timetable", "path"]
    ary = [keys, values].transpose
    avatar_info = Hash[*ary.flatten]
    # hashをjsonにして返す
    render json: avatar_info
  end

  def edit
    @avatar = Avatar.find(params[:id])
  end

  def update
    @avatar = Avatar.find(params[:id])
    # 旅行終了ボタン押したときだけ↓のifに (path.csvに最後の駅だけ残す)
    if params.require(:avatar)[:end]
      CSV.open("db/csv/#{@avatar.id}_path.csv", "w") do |content|
        content << [Station.find(@avatar.curr_station_id).lat, Station.find(@avatar.curr_station_id).long]
      end
    end
    @avatar.update_attributes(avatar_params)
    if @avatar.save
      respond_to do |format|
        format.html { redirect_to root_path, notice: "アバター情報を変更しました" }
        format.json
      end
    end
  end

  private

  def avatar_params
    params.require(:avatar).permit(:name, :avatar_type, :stage,
                                   :curr_station_id, :last_station_id, :home_station_id,
                                   :curr_location_lat, :last_location_lat,
                                   :curr_location_long, :last_location_long, :train_timetable).merge(user_id: current_user.id)
  end
end
