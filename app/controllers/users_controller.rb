require "time"

class UsersController < ApplicationController
  def index
    if user_signed_in?
      gon.avatars = current_user.avatars
      gon.current_user = current_user
      @user = User.find(current_user.id)
    end

    @station = Station.find(Avatar.find(current_user.avatars[0].id).curr_station_id)
    # to do @positionを取得後、 Avatarのcurr_station_id, curr_lat, curr_long更新
    # ログアウトor終了時に avatarsにlast_station_id
    @train_timetable = Travel.getCurrentTrainTimetable(@station, "2:00")
    @position = Travel.getTrainPosition(@train_timetable, "4:00")
  end

  def reload_user
    render json: current_user
  end

  def show
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
