class PassedStation < ApplicationRecord
  belongs_to :avatar
  belongs_to :station

  validates :has_passed, presence: true
end
