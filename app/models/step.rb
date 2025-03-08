class Step < ApplicationRecord
  belongs_to :goal
  has_one :calendar, dependent: :destroy

  validates :description, :estimated_minute, :status, presence: true, uniqueness: { scope: :goal_id }
end
