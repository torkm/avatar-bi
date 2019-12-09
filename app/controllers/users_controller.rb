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
