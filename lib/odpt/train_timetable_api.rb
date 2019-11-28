
module Odpt
  class TrainTimetableAPI < TrainAPI
    PATH = "TrainTimetable"

    def self.fetch(params)
      make_get_request(PATH, params)
    end
  end
end
