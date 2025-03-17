class TimeSlot < ApplicationRecord
  belongs_to :goal
  has_one :calendar

  validates :day_of_week, presence: true
  validates :start_time, :end_time, presence: true
  validate :end_time_must_be_after_start_time
  validate :validate_overlap

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

  private

  def overlap?
    same_day_time_slots = TimeSlot.where(day_of_week: self.day_of_week)

    # Vérifier s'il y a un chevauchement avec un autre time_slot du même jour
    same_day_time_slots.each do |slot|
      if (slot.start_time...slot.end_time).overlaps?(self.start_time...self.end_time)
        return true
      end
    end

    false
  end

  def validate_overlap
    errors.add(:base, "Ce créneau horaire est déjà pris") if overlap?
  end

end
