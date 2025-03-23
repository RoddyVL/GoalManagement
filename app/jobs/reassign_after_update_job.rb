class ReassignAfterUpdateJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    # on définis les variables nécessaires pour pouvoir execurer ce job
    goal = Goal.find(goal_id)
    if goal.sessions.order(:start_time).last.end_time < Time.current
      reference_date_and_time = Time.current
    else
      reference_date_and_time = goal.sessions.order(:start_time).last.end_time
    end
    reference_day = reference_date_and_time.wday
    time_slots = goal.time_slots.order(:day_of_week, :start_time).to_a     # On récupère les instance de 'time_slot' que l'on transforme en array et qu'on classe par jour et heure

    # On récupère tout les steps à réassinger tout les steps planifiés pour aujourd'hui ou dans le future
    # On récupère les futures sessions afin d'y assigné les steps
    future_sessions = Session.where("start_time >= ?", Time.current).to_a.sort_by(&:start_time)
    future_steps = future_sessions.flat_map { |session| session.steps }.sort_by(&:id)
    step_to_assign =  Step.where(session: nil)
    puts "step to assign: #{step_to_assign.length}"
    steps_to_reassign = future_steps + step_to_assign
    puts "future sessions: #{future_sessions.length}"
    puts "future steps: #{future_steps.length}"
    puts Step.where(status: 0).length
    puts "steps to reassign: #{steps_to_reassign.length}"





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

            # on planifie la réassignation automatique des steps chaque jour à 00:01
          ReassignStepsJob.set(wait_until: Time.current.beginning_of_day + 1.day).perform_later
        end
      end
    end

  end
end
