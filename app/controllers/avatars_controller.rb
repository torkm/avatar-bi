class AvatarsController < ApplicationController
  protect_from_forgery except: :create

  def new
    @avatar = Avatar.new
  end

  def create
    @avatar = Avatar.new(avatar_params)
    if @avatar.save
      redirect_to root_path, notice: "アバターを登録しました"
    else
      render :new
    end
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
