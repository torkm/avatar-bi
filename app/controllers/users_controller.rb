require "time"

class UsersController < ApplicationController
  def index
    if user_signed_in?
      gon.avatars = current_user.avatars
      gon.current_user = current_user
    end
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
    this_time_i  = params[:this_travel_time].to_i
    total_time_i = params[:total_travel_time].to_i
    binding.pry
    this_time_t  = Time.at(this_time_i);p this_time_t
    total_time_t = Time.at(total_time_i);p total_time_t
    params[:this_travel_time] = this_time_t
    params[:total_travel_time] = total_time_t
    params.permit(:this_travel_time, :total_travel_time, :name)
  end
end
