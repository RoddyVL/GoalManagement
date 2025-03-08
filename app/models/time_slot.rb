class TimeSlot < ApplicationRecord
  belongs_to :goal
  has_one :calendar

  validates :day_of_week, presence: true
  validates :start_time, :end_time, presence: true

  enum day_of_week: {
    lundi: 0,
    mardi: 1,
    mercredi: 2,
    jeudi: 3,
    vendredi: 4,
    samedi: 5,
    dimanche: 6
  }, _prefix: true
end
