class TimeSlot < ApplicationRecord
  belongs_to :goal
  has_one :calendar

  validates :day_of_week, presence: true
  validates :start_time, :end_time, presence: true
  validate :end_time_must_be_after_start_time

  enum day_of_week: {
    lundi: 0,
    mardi: 1,
    mercredi: 2,
    jeudi: 3,
    vendredi: 4,
    samedi: 5,
    dimanche: 6
  }, _prefix: true

  def end_time_must_be_after_start_time
    if end_time.present? && start_time.present? && end_time <= start_time
      errors.add(:end_time, "doit être après l'heure de début")
    end
  end
end
