class RedefineSlotsJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    goal = Goal.find(goal_id)
    goal.steps.where(status: 0).update_all(session_id: nil)
    goal.sessions.where('start_time >= ?', Time.current).delete_all

    GeneratePlanningJob.perform_now(goal_id)
  end
end
