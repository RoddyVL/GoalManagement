class RedefineSlotsJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    # On récupère toutes les données nécessaire pour faire fonctionner l'algorithme
    goal = Goal.find(goal_id)
    puts "goal: #{goal.description}"
    slots = goal.time_slots.map(&:day_of_week_before_type_cast)
    puts "slots: #{slots} - #{slots.length}"
    sessions = goal.sessions.where("start_time >= ?", Time.current)
    puts "sessions: #{sessions.to_a} - #{sessions.length}"
    sessions_to_delete = sessions.reject { |session| slots.include?(session.start_time.wday) }     # sessions_to_delete = sessions.where.not("EXTRACT(DOW FROM start_time) IN (?)", slots)
    puts "session to delete: #{sessions_to_delete} - #{sessions_to_delete.length}"
    steps_to_disconect = sessions_to_delete.flat_map(&:steps)
    steps_to_disconect.each do |step|
      step.update(session: nil)
    end
    sessions_to_delete.each(&:destroy) if sessions_to_delete.any?
    steps_without_session = goal.steps.where(session: nil).to_a
    puts "steps without session: #{steps_without_session} - #{steps_without_session.to_a.length}"
    future_sessions = Session.where("start_time >= ?", Time.current).to_a.sort_by(&:start_time)
    future_steps = future_sessions.flat_map { |session| session.steps }.sort_by(&:priority)
    puts "future sessions: #{future_sessions.length}"
    puts "future steps: #{future_steps.length}"
    steps_to_reassign = (steps_without_session + future_steps).sort_by(&:priority)
    puts "steps to reassign: #{steps_to_reassign.length}"

    reference_date_and_time = Time.current
    reference_day = reference_date_and_time.wday
    time_slots = goal.time_slots.order(:day_of_week, :start_time).to_a

    # On lance l'algorithme
     # jusqu'à ce qu'il n'y ai plus de 'steps à réassinger', si il y a des 'futures sessions', on va assigner les 'steps' à une 'session' tant que la somme de leur durée est inférieur au temps totale disponible
     unless steps_to_reassign.empty?
      if future_sessions.any?
        future_sessions.each do |session|
          steps_total_time = 0
          while steps_total_time < session.total_time && steps_to_reassign.any?
            step = steps_to_reassign.shift
            step.update(session: session) unless step&.session == session
            steps_total_time += step.estimated_minute
            puts "step total time: #{steps_total_time} - session total time: #{session.total_time}"
          end
          future_sessions.shift
          puts "future session: #{future_sessions.length}"
        end
      else
        while steps_to_reassign.any?
          next_time_slot = time_slots.detect do |slot|
            (slot.day_of_week_before_type_cast == reference_day && slot.start_time > reference_date_and_time.time) || slot.day_of_week_before_type_cast > reference_day
          end
          next_time_slot = time_slots.first unless next_time_slot
          puts "next_time_slot: #{next_time_slot}"

          # 2. on convertit le slot en une date et heure exploitable pour instancier une session
          day_to_add = (next_time_slot.day_of_week_before_type_cast - reference_day) % 7       # On calcul le nombre de jour qu'il faut rajouter à reference_date pour avoir la date qui correspond au 'slot"
          puts "day_to_add: #{day_to_add}"

          session_date = reference_date_and_time + day_to_add.days    # on définis la date de la session
          start_datetime = session_date.change(hour: next_time_slot.start_time.hour, min: next_time_slot.start_time.min)  # on définit le 'start_time' et le end_time de la session
          end_datetime = session_date.change(hour: next_time_slot.end_time.hour, min: next_time_slot.end_time.min)
          puts "session date: #{session_date}"
          puts "start datetime #{start_datetime}"
          puts "end datetime #{end_datetime}"

          # 3. On instancie une 'session' avec ses attributs
          puts "create session"
          session = Session.create(start_time: start_datetime, end_time: end_datetime, goal: goal)
          puts "session: #{session.start_time} - #{session.end_time}"

            # 4. on assigne des steps à la session tant que la somme de leur durée est inférieur ou égale à la durée de la session
          steps_total_time = 0
          while steps_total_time <= session.total_time && steps_to_reassign.any?
            step = steps_to_reassign.shift
            step.update(session: session)
            steps_total_time += step.estimated_minute
            puts "step total time: #{steps_total_time} - session total time: #{session.total_time}"
          end

          # 5. on réassigne ses valeurs pour la prochaine itération
          reference_date_and_time = session.end_time
          reference_day = reference_date_and_time.wday
          puts "new reference datetime: #{reference_date_and_time} - #{reference_day}"
        end
      end
    end
  end
end
