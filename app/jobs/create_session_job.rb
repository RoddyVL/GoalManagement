class CreateSessionJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    goal = Goal.find(goal_id)
    session_created =  goal.sessions.order(id: :desc).first
    puts "session created: #{session_created.start_time}"

    goal.steps.where(status: 0).update_all(session_id: nil) # && goal.steps.where('session.start_time >= ?' Time.current)
    goal.sessions.where('start_time > ?', session_created.end_time).delete_all
    puts "deleted? #{goal.sessions.where('start_time > ?', session_created.end_time).count}"
    ReassignAfterUpdateJob.perform_now(goal_id)
  end
end
