class Step < ApplicationRecord
  belongs_to :goal
  belongs_to :session, optional: true

  validates :description, presence: true, uniqueness: { scope: :goal_id }
  validates :estimated_minute, presence: true
end
