module Odpt
  class StationTimetableAPI < TrainAPI
    PATH = "StationTimetable"

    def self.fetch(params)
      make_get_request(PATH, params)
    end
  end
end
