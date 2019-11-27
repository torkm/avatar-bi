class Railway < ApplicationRecord
  has_many :stations
  has_many :passed_railways
  has_many :avatars, through: :passed_railways

  validates :name, :operator, :station_num, presence: true
end
