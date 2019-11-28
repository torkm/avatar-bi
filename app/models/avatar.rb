class Avatar < ApplicationRecord
  belongs_to :user
  has_many :passed_stations
  has_many :stations, through: :passed_stations
  has_many :passed_railways
  has_many :railways, through: :passed_railways

  validates :name, :type, :stage,:curr_station_id, :last_station_id, :home_station_id, presence: true
end
