class StationsController < ApplicationController
  def index
    search_stations = Station.where(['name LIKE ?', "#{params[:keyword]}%"] ).limit(50)
    @stations = search_stations.select{|s| s.railway[:has_TrainTimetable]==true 
                                        && s.id != 214 && s.id != 154 && s.id != 213 && s.id != 188 && s.id != 167}
    respond_to do |format|
      format.json
      format.html{redirect_to new_avatar_path}
    end
  end



end
