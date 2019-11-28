module Odpt
  class StationAPI < TrainAPI
    PATH = "Station"

    def self.fetch(params)
      make_get_request(PATH, params)
    end
  end
end
