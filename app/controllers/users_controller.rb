require "time"

class UsersController < ApplicationController
  def index
    if user_signed_in?
      if current_user.avatars[0] == nil then
        redirect_to '/avatars/new' , notice: "ログインしました。アバターを持っていません"
      else

        # csvなかった場合、作成
        avatar = current_user.avatars[0]
        # avatar複数ならここからループ

        unless File.exist?("db/csv/#{avatar.id}_curr.csv")
          sta = Station.find(avatar.home_station_id)
          CSV.open("db/csv/#{avatar.id}_curr.csv", "w") do |content|
            content << [sta.id, sta.odpt_sameAs, sta.name, sta.railway.jname, sta.lat, sta.long, sta.id, sta.name, 0, ""]
            # 現在駅id, 現在駅sameAs, 現在駅名, 現在路線, 現在lat, 現在long, 次駅id, 次駅名, 進行方向の角度, 現在時刻表
          end
        end

        gon.avatars = current_user.avatars
        # 1-9でアイコンタイプを指定
        gon.icon_type = avatar.avatar_type + 3 * (avatar.stage - 1)
        gon.current_user = current_user
      end
    end
  end

  def reload
    render json: current_user
  end

  def show
    if current_user.id != params[:id].to_i
      redirect_to root_path
    end

    avatar = current_user.avatars[0]
    # 複数ならここから下ループ

    # 全駅数と路線数は計算量節約のため定数で(下が計算式)
    @total_st, @total_rw = 1173, 62
    # @total_rw = Railway.where(has_TrainTimetable: true).count  #全路線数
    # Railway.where(has_TrainTimetable: true).each do |r|
    #   @total_st += r.station_num  #各路線の総駅数を足す
    # end

    @comp_rw = 0 # 制覇路線数
    @comp_st = 0 # 制覇駅数
    # {路線名: [路線id, 踏破駅数,総駅数,残り駅数]}の組み合わせ(1つでも行っていたら)をhashで保存
    @passed_rw_st = {}
    avatar.passed_stations.each do |p|
      if p.has_passed != 0 # 踏破してたらhashに追加 (路線で初なら新規, あれば+1)
        @comp_st += 1
        rw = Station.find(p.station_id).railway
        if @passed_rw_st.has_key?(rw.jname)
          @passed_rw_st[rw.jname][1] += 1
          @passed_rw_st[rw.jname][3] -= 1
        else
          @passed_rw_st[rw.jname] = [rw.id, 1, rw.station_num, rw.station_num - 1]
        end
      end
    end

    # Passed_railwaysテーブルに踏破路線を保存
    @passed_rw_st.each do |key, value|
      if value[3] == 0 #全駅踏破
        @comp_rw += 1
        p_r = PassedRailway.new(avatar_id: current_user.avatars[0].id, railway_id: value[0])
        unless PassedRailway.find_by(avatar_id: p_r.avatar_id, railway_id: p_r.railway_id)
          p_r.save
        end
      end
    end

    # アバターのレベルを判定してアイコン表示  画像ファイルの番号も指定
    if @comp_st < 200
      avatar.stage = 1
    elsif @comp_st < 1000
      avatar.stage = 2
    else
      avatar.stage = 3
    end 
    avatar.save
    @avatar_type = (avatar.avatar_type + 3*(avatar.stage-1)).to_s 

    # ランキングを表示
    h = User.order("total_travel_time DESC").pluck(:id)
    @rank_time = h.index(avatar.id) + 1

    h = PassedStation.group(:avatar_id).count
    h = Hash[ h.sort_by{ |_, v| -v } ]
    @rank_station = h.keys.index(avatar.id) + 1

    h = PassedRailway.group(:avatar_id).count
    h = Hash[ h.sort_by{ |_, v| -v } ]
    @rank_railway = h.keys.index(avatar.id) + 1

    # 地図を表示 [路線名, 路線id, 駅名, lat, long, has_passed, passed_at]を返す
    gon.avatar = avatar
    gon.icon_type = avatar.avatar_type + 3 * (avatar.stage - 1)
    gon.stations = []
    PassedStation.where(avatar_id: avatar.id).where("has_passed > ?", 0).each do |ps|
      gon.stations << [ps.station.railway.jname, ps.station.railway_id, ps.station.name, ps.station.lat, ps.station.long, ps.has_passed, ps.updated_at]
    end
  end

  def edit
  end

  def update
    if current_user.update(update_params)
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json
      end
    end
  end

  private

  def update_params
    params.permit(:is_moving,
                  :start_time, :start_pos_lat, :start_pos_long,
                  :end_time, :end_pos_lat, :end_pos_long,
                  :this_travel_time, :total_travel_time)
  end
end
