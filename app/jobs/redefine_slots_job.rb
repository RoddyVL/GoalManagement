class RedefineSlotsJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    goal = Goal.find(goal_id)

    future_sessions = goal.sessions.where('start_time >= ?', Time.current)
    goal.steps.where(session_id: future_sessions.pluck(:id)).update_all(session_id: nil)
    future_sessions.delete_all
    
    GeneratePlanningJob.perform_now(goal_id)
  end
end
