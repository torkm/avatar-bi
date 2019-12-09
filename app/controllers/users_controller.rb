require "time"

class UsersController < ApplicationController
  def index
    if user_signed_in?
      # csvなかった場合、作成
      unless File.exist?("db/csv/#{current_user.avatars[0].id}_curr.csv")
        a_id = current_user.avatars[0].id
        sta = Station.find(Avatar.find(a_id).home_station_id)
        CSV.open("db/csv/#{current_user.id}_curr.csv", "w") do |content|
          content << [sta.id, sta.odpt_sameAs, sta.name, sta.railway.jname, sta.lat, sta.long, sta.id, sta.name, 0, ""]
          # 現在駅id, 現在駅sameAs, 現在駅名, 現在路線,　現在lat, 現在long, 次駅id, 次駅名, 進行方向の角度, 現在時刻表
        end
      end
      # passed_stationsのためのcsv 現在は使わない予定
      # unless File.exist?("db/csv/#{current_user.id}_#{current_user.avatars[0].id}_record.csv")
      #   CSV.open("db/csv/#{current_user.id}_#{current_user.avatars[0].id}_record.csv", "w") do |content|
      #     content << [0,"","",0,"",0,0,Time.now]
      #     # 駅id, 駅sameAs, 駅名, 路線id, 路線名, 通過回数, 最新到着時刻
      #   end
      # end

      gon.avatars = current_user.avatars
      gon.current_user = current_user
    end
  end

  def reload
    render json: current_user
  end

  def show
    if current_user.id != params[:id].to_i
      redirect_to root_path
    end

    # 全駅数と路線数は計算量節約のため定数で
    @total_st, @total_rw = 1086, 60
    # @total_st = PassedStation.where(avatar_id: current_user.avatars[0].id).count # 全駅数
    # @total_rw = Railway.where(has_TrainTimetable: true).count  #全路線数

    @comp_rw = 0 # 制覇路線数
    @comp_st = 0 # 制覇駅数
    # 踏破した路線と駅の組み合わせをhashで保存
    @passed_rw_st = {}
    current_user.avatars[0].passed_stations.each do |p|
      if p.has_passed != 0 # 踏破してたらhashに追加 (路線で初なら新規, あれば+1)
        @comp_st += 1
        rw = Station.find(p.station_id).railway.jname
        if @passed_rw_st.has_key?(rw)
          @passed_rw_st[rw] += 1
        else
          @passed_rw_st[rw] = 1
        end
      end
    end

    # Passed_railwaysテーブルに踏破路線を保存
    @passed_rw_st.each do |key, value|
      railway = Railway.find_by(jname: key)
      if value == railway.station_num
        p_r = PassedRailway.new(avatar_id: current_user.avatars[0].id, railway_id: railway.id)
        p_r.save
        @comp_rw += 1
      end
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
