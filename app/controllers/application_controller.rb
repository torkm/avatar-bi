class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :this_travel_time, :total_travel_time, :start_time, :end_time, :start_pos_lat, :start_pos_long, :end_pos_lat, :end_pos_long, :is_moving])
  end
end
