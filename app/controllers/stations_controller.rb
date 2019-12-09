class StationsController < ApplicationController
  def index
    search_stations = Station.where(['name LIKE ?', "#{params[:keyword]}%"] ).limit(50)
    @stations = search_stations.select{|s| s.railway[:has_TrainTimetable]==true}
    respond_to do |format|
      format.json
      format.html{redirect_to new_avatar_path}
    end
  end



end
