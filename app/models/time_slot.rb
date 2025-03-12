class TimeSlot < ApplicationRecord
  belongs_to :goal
  has_one :calendar

  validates :day_of_week, presence: true
  validates :start_time, :end_time, presence: true
  validate :end_time_must_be_after_start_time

  enum day_of_week: {
   monday: 1,
    Tuesday: 2,
    Wednesday: 3,
    Thursday: 4,
    Friday: 5,
    Saturday: 6,
    Sunday: 0
  }, _prefix: true

  def total_time
    (end_time - start_time) / 60
  end

  def end_time_must_be_after_start_time
    if end_time.present? && start_time.present? && end_time <= start_time
      errors.add(:end_time, "doit être après l'heure de début")
    end
  end
end
