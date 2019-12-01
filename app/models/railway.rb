class Railway < ApplicationRecord
  has_many :stations
  has_many :passed_railways
  has_many :avatars, through: :passed_railways

  validates :jname, :name, :operator, :station_num, presence: true
end
