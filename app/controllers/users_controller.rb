require "time"

class UsersController < ApplicationController
  def index
    if user_signed_in?
      gon.avatars = current_user.avatars
      gon.current_user = current_user
      gon.global.curr_location_lat = current_user.avatars[0].curr_location_lat
      gon.global.curr_location_long = current_user.avatars[0].curr_location_long
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
