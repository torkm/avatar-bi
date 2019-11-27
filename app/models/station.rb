class Station < ApplicationRecord
  belongs_to :railway
  has_many :passed_stations
  has_many :avatars, through: :passed_stations

  validates :name, :station_code, :lat, :long, presence: true
end
