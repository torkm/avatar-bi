module Odpt
  class RailwayAPI < TrainAPI
    PATH = "Railway"

    def self.fetch(params)
      make_get_request(PATH, params)
    end
  end
end
