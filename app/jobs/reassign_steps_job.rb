class ReassignStepsJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    today = Date.current
    goal = Goal.find(goal_id)
    time_slots = goal.time_slots.order(:day_of_week, :start_time).to_a
    reference_datetime = Time.current
    reference_day = reference_datetime.wday

    # Récupérer les sessions passées qui contiennent des steps non complétés
    past_sessions = goal.sessions.where("DATE(end_time) < ?", Date.current)
    steps_to_assign = goal.steps.where(session: goal.sessions.first).or(goal.steps.where(session: nil))
    steps_to_reassign = past_sessions.flat_map { |session| session.steps.where(status: 0) }.sort_by(&:id)
    steps_to_reassign += steps_to_assign
    future_sessions = goal.sessions.where("end_time >= ?", today).order(:start_time)

    # Assigner les steps aux sessions futures
    future_sessions&.each do |session|
      steps_total_time = 0
      while steps_to_reassign.any? && (steps_total_time + steps_to_reassign.first.estimated_minute) <= session.total_time
        step = steps_to_reassign.shift
        step.update!(session_id: session.id)
        puts "Step #{step.id} réassigné à la session #{session.id}"
        steps_total_time += step.estimated_minute
      end
    end

    # Créer des nouvelles sessions si nécessaire
    while steps_to_reassign.any?
      next_time_slot = time_slots.detect do |slot|
        (slot.day_of_week == reference_day && slot.start_time > reference_datetime.time) || slot.day_of_week > reference_day
      end
      next_time_slot ||= time_slots.first

      unless next_time_slot
        Rails.logger.info "Erreur : Aucun créneau disponible"
        break
      end

      day_to_add = (next_time_slot.day_of_week - reference_day) % 7
      session_date = reference_datetime + day_to_add.days
      start_datetime = session_date.change(hour: next_time_slot.start_time.hour, min: next_time_slot.start_time.min)
      end_datetime = session_date.change(hour: next_time_slot.end_time.hour, min: next_time_slot.end_time.min)

      session = Session.create(start_time: start_datetime, end_time: end_datetime, goal: goal)
      unless session.persisted?
        Rails.logger.info "Erreur : impossible de créer la session"
        break
      end

      # assigner les steps aux nouvelles sessions
      steps_total_time = 0
      while steps_to_reassign.any? && (steps_total_time + steps_to_reassign.first.estimated_minute) <= session.total_time
        step = steps_to_reassign.shift
        step.update!(session: session)
        steps_total_time += step.estimated_minute
      end

      reference_datetime = session.end_time
      reference_day = reference_datetime.wday
    end

    puts "Nouvelles sessions créées : #{Session.where(goal_id: 2).where("end_time >= ?", Date.current).count}"

  end
end
