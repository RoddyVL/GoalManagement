class Step < ApplicationRecord
  belongs_to :goal
  has_one :calendar, dependent: :destroy

  validates :description, presence: true, uniqueness: { scope: :goal_id }
  validates :estimated_minute, presence: true
end
