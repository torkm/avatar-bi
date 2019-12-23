require "time"
require "csv"

class AvatarsController < ApplicationController
  protect_from_forgery except: :create

  before_action :set_current_avatar, only: [:new, :travel, :reload]

  def set_current_avatar
    @current_avatar = current_user.avatars[0]
  end

  def new
    if @current_avatar
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
      PassedStation.create(avatar_id: @avatar.id, station_id: @avatar.curr_station_id, has_passed: 1, passed_at: Time.now)

      # アバター作成時、csvを作成
      sta = Station.find(@avatar.home_station_id)
      empty_timetable = ""
      CSV.open("db/csv/#{@avatar.id}_curr.csv", "w") do |content|
        content << [sta.id, sta.odpt_sameAs, sta.name, sta.railway.jname, sta.lat, sta.long, sta.id, sta.name, 0, empty_timetable]
      end
      CSV.open("db/csv/#{@avatar.id}_path.csv", "w") do |content|
        content << [@avatar.curr_location_lat, @avatar.curr_location_long]
      end
      redirect_to root_path, notice: "アバターを登録しました"
    else
      # redirect_to new_avatar_path
      render 'new'
      return
    end
  end

  def travel

    #############  これを一定時間でループ   #############
    starting_id = @current_avatar.curr_station_id
    @train_timetable = eval(@current_avatar.train_timetable) #avatarから呼び出し、配列に変換
    @time = Time.now

    unless @train_timetable # avatarが時刻表持っていない場合(= 旅行開始時、終点に着いて次の移動)
      station = Station.find(starting_id)
      @train_timetable = Travel.getCurrentTrainTimetable(station, @time)[0]  #Aで時刻表ゲット
    end

    @position = Travel.getTrainPosition(@train_timetable, @time) #Bで現在地更新
    # ② 終点についていたらtrain_timetable 削除
    if @position[0] == @train_timetable[-1][2] #終点についていたら削除
      @train_timetable = ""
    end

    # ③-1  DB操作 (avatar)
    @current_avatar.train_timetable = @train_timetable.to_s # 文字列にして時刻表更新
    @current_avatar.curr_station_id = @position[0]
    @current_avatar.curr_location_lat = @position[2]
    @current_avatar.curr_location_long = @position[3]
    # curr_locationはユーザー詳細ページで使用
    @current_avatar.save

    #③-2  DB操作 (passed_station): current駅が変わっていたら、
    #・[avatar_id, 通過駅_id]の組み合わせをpassed_stationに保存
    # ・最新駅一個手前の駅までの、今回の移動で行った駅の座標csvに保存
    unless starting_id == @position[0]
      # すでに一度訪れているなら、レコード利用 / なかったら、新規作成
      @passed_station = @current_avatar.passed_stations.find_by(station_id: @position[0])
      if @passed_station
        @passed_station.has_passed += 1
        @passed_station.passed_at = @time
      else
        @passed_station = PassedStation.new(avatar_id: @current_avatar.id, station_id: @position[0], has_passed: 1, passed_at: @time)
      end
      @passed_station.save
      

    # 現在駅が更新されるごとに、id_path.csvファイルに最新の駅座標を格納
      
  
    CSV.open("db/csv/#{@current_avatar.id}_path.csv", "a") do |content|
        content << [@position[2], @position[3]]
      end
    end
    # ④ 現在位置などはcsvに保存
    # 現在駅id, 現在駅sameAs, 現在駅名, 現在路線,　現在lat, 現在long, 次駅id, 次駅名, 進行方向の角度, 現在時刻表
    #position 5,6はcurr_station,next_station
    sta = @position[5]
    n_sta = @position[6]
    railway_name = @position[7]

    
    CSV.open("db/csv/#{@current_avatar.id}_curr.csv", "w") do |content|
      content << [sta[2], sta[5], sta[4], railway_name, @position[2], @position[3], n_sta[2], n_sta[5], @position[4], @train_timetable]
    end

    ###############################################
  end

  def reload
    # avatar複数の時は行をループ
    # values = CSV.read("db/csv/#{current_user.id}_curr.csv")[0]
    values = CSV.read("db/csv/#{@current_avatar.id}_curr.csv")[0]
    if File.exist?("db/csv/#{@current_avatar.id}_path.csv")
      path = CSV.read("db/csv/#{@current_avatar.id}_path.csv")
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
        station = Station.find(@avatar.curr_station_id)
        content << [station.lat, station.long]
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
