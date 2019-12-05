require "time"

class UsersController < ApplicationController
  def index
    if user_signed_in?
      gon.avatars = current_user.avatars
      gon.current_user = current_user

      @user = User.find(current_user.id)
      @avatar = Avatar.find(@user.avatars[0].id)

      #############  これを一定時間でループ   #############
      @station = Station.find(@avatar.curr_station_id)
      @train_timetable = eval(@avatar.train_timetable) #avatarから呼び出し、配列に変換
      unless @train_timetable # avatarが時刻表持っていない場合(= 旅行開始時、終点に着いて次の移動)
        @train_timetable = Travel.getCurrentTrainTimetable(@station, "13:22")  #Aで時刻表ゲット
      end
      @position = Travel.getTrainPosition(@train_timetable, "13:22") #Bで現在地更新
      # ② 終点についていたらtrain_timetable 削除
      if @position[0] == @train_timetable[-1][0] #終点についていたら削除
        @train_timetable = ""
      end

      # ③ DB操作
      @avatar.train_timetable = @train_timetable.to_s # 文字列にして時刻表更新
      @avatar.curr_station_id = Station.find_by(odpt_sameAs: @position[0]).id
      @avatar.curr_location_lat = @position[2]
      @avatar.curr_location_long = @position[3]
      @avatar.save

      gon.curr_location_lat = @position[2]
      gon.curr_location_long = @position[3]
      gon.viewangle = @position[4]
      ###############################################
    end
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
