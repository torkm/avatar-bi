class StationsController < ApplicationController
  def index
    @stations = Station.where(['name LIKE ?', "%#{params[:keyword]}%"] ).limit(50)
    respond_to do |format|
      format.json
      format.html{redirect_to new_avatar_path}
    end
  end
end
