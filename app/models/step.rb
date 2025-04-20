class Step < ApplicationRecord
  belongs_to :goal
  belongs_to :session, optional: true

  validates :description, presence: true, uniqueness: { scope: :goal_id }
  validates :estimated_minute, presence: true
  validate :session_and_goal_must_match

  private

  def session_and_goal_must_match
    if session && session.goal_id != goal_id
      errors.add(:session, "must belong to the same goal as the step")
    end
  end
end
