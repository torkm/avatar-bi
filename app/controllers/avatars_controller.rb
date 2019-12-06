require 'time'

class AvatarsController < ApplicationController
  protect_from_forgery except: :create

  def new
    @avatar = Avatar.new
  end

  def create
    @avatar = Avatar.new(avatar_params)
    if @avatar.save
      stations = Station.select{|s| s.railway[:has_TrainTimetable]==true}
      stations.each do |station|
        passed_station = PassedStation.new(avatar_id: @avatar.id, station_id: station.id)
        passed_station.save
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

    @station = Station.find(@avatar.curr_station_id)
    @train_timetable = eval(@avatar.train_timetable) #avatarから呼び出し、配列に変換
    unless @train_timetable # avatarが時刻表持っていない場合(= 旅行開始時、終点に着いて次の移動)
      @train_timetable = Travel.getCurrentTrainTimetable(@station, Time.now)  #Aで時刻表ゲット
    end
    @position = Travel.getTrainPosition(@train_timetable, Time.now) #Bで現在地更新
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

    # gon.global.curr_location_lat = @position[2]
    # gon.global.curr_location_long = @position[3]
    # gon.global.viewangle = @position[4]
    ###############################################
  end 

  def reload
    render json: current_user.avatars
  end

  def edit
  end

  def update
    @avatar = Avatar.find_by(id: params[:id])
    @avatar.update_attributes(update_params)
    if @avatar.save
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json
      end
    end
  end

  private
  def avatar_params
    params.require(:avatar).permit(:name, :avatar_type, :stage,
                                   :curr_station_id,    :last_station_id, :home_station_id,
                                   :curr_location_lat,  :last_location_lat,
                                   :curr_location_long, :last_location_long).merge(user_id: current_user.id)
  end

  def update_params
    # params.permit(:last_station_id, :last_location_lat, :last_location_long, :tarin_timetable)
    params.permit(:name, :avatar_type, :stage,
                  :curr_station_id,    :last_station_id, :home_station_id,
                  :curr_location_lat,  :last_location_lat,
                  :curr_location_long, :last_location_long, :train_timetable)
  end

end
