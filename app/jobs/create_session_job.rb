class CreateSessionJob < ApplicationJob
  queue_as :default

  def perform(goal_id, session_id)
    puts "job started"
    goal = Goal.find(goal_id)
    session_created =  Session.find(session_id)
    puts "session created: #{session_created.start_time} - #{session_created.end_time}"
    goal.steps.where(session_id: Session.where('start_time > ?', session_created.start_time)).update_all(session_id: nil)
    goal.sessions.where('start_time > ?', session_created.start_time).delete_all
    puts "deleted? #{ goal.sessions.where('start_time > ?', session_created.start_time).size}"
    ReassignAfterUpdateJob.perform_now(goal_id)
  end
end
