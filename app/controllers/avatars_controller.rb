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

  private
  def avatar_params
    params.require(:avatar).permit(:name, :type,:stage,:curr_station_id, :last_station_id, :home_station_id)
    # .merge(user_id: current_user.id)
  end

end
