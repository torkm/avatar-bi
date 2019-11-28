class Station < ApplicationRecord
  belongs_to :railway
  has_many :passed_stations
  has_many :avatars, through: :passed_stations

  validates :name, :odpt_sameAs, :lat, :long, presence: true
end
