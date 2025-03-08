class TimeSlot < ApplicationRecord
  belongs_to :project
  has_one :calendar

  validates :day_of_week, :start_time, :end_time, presence: true, uniqueness: { scope: :goal_id }
end
