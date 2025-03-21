class GeneratePlanningJob < ApplicationJob
  queue_as :default

  def perform(goal_id)

    #  on récupère tout les éléments nécessaires à l'execution du code
    goal = Goal.find_by(id: goal_id)     # on récupère la goal afin d'accéder à tout les modèles qui lui appartiennent
    time_slots = goal.time_slots.order(:day_of_week, :start_time).to_a     # On récupère les instance de 'time_slot' que l'on transforme en array et qu'on classe par jour et heure
    steps_to_assign = goal.steps.where(session: goal.sessions.first).or(goal.steps.where(session: nil))     # on récupère toutes les étapes qui sont assigné à la session par défaut ou qui n'ont pas de session
    steps_to_assign = steps_to_assign.order(:id).to_a
    reference_date_and_time = Time.current #on récupère le jour et l'heure à partir de laquelle on cherchera la prochaine disponibilité
    reference_day = reference_date_and_time.wday
    puts "goal: #{goal.description}"
    puts "time slots#{time_slots}"
    puts "step to assign: #{steps_to_assign}"
    puts "reference date and time: #{reference_date_and_time}"
    puts "reference_day: #{reference_day}"

    # on démarre une boucle qui s'arrêtera uniquement lorsqu'il n'y aura plus d'étapes à assigné.
    while steps_to_assign.any?

      # 1. On récupère la prochaine disponibilité dans 'time_slots'
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
      while steps_total_time <= session.total_time && steps_to_assign.any?
        step = steps_to_assign.shift
        step.update(session: session)
        steps_total_time += step.estimated_minute
        puts "step total time: #{steps_total_time} - session total time: #{session.total_time}"
      end

      # 5. on réassigne ses valeurs pour la prochaine itération
      reference_date_and_time = session.end_time
      reference_day = reference_date_and_time.wday
      puts "new reference datetime: #{reference_date_and_time} - #{reference_day}"

    end
    # on planifie la réassignation automatique des steps chaque jour à 00:01
    ReassignStepsJob.set(wait_until: Time.current.beginning_of_day + 1.day).perform_later
  end
end
