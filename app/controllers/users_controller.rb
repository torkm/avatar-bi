require "time"

class UsersController < ApplicationController
  def index
    if user_signed_in?
      gon.avatars = current_user.avatars
      gon.current_user = current_user
      @user = User.find(current_user.id)
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

    unless (params[:start_time] == nil) then
      time = params[:start_time]
      params[:start_time] = Time.parse(params[:start_time])
    end
    params.permit(:is_moving, :start_time, :this_travel_time, :total_travel_time)
  end
end
