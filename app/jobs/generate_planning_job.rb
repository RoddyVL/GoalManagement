class GeneratePlanningJob < ApplicationJob
  queue_as :default

  def perform(goal_id)

    goal = Goal.find_by(id: goal_id)
    puts "goal: #{goal}"
    # on récupère l'heure et la date à laquelle la méthode est appelé methode_date
    method_date_and_time = Time.current
    method_day = method_date_and_time.wday
    puts "method_day: #{method_day}"

    # On récupère les instance de 'slot' que l'on transforme en array et qu'on classe par jour et heure
    time_slots = goal.time_slots.order(:day_of_week, :start_time).to_a
    puts "time_slots#{time_slots}"

    # On récupère soit la prochaine disponibilité du jour avec un start_time strictement supérieur. Sinon on récupère les autres jours de la semaine jusqu'à trouver le premier
    next_time_slot = time_slots.detect do |slot|
      (slot.day_of_week_before_type_cast == method_day && slot.start_time > method_date_and_time.time) || slot.day_of_week_before_type_cast > method_day
    end

    puts "next_time_slot: #{next_time_slot.day_of_week_before_type_cast}"

    # On calcul le nombre de jour qu'il faut rajouter à method_date pour avoir la date qui correspond au 'slot"
    day_to_add = next_time_slot.day_of_week_before_type_cast - method_day   # je vais garder cela pour le moment mais cette méthode est fragile et ne gère pas tout les cas
    puts "day_to_add: #{day_to_add}"

    new_date = method_date_and_time + day_to_add.days
    puts "new date: #{new_date}"
    start_datetime = new_date.to_datetime.change(hour: next_time_slot.start_time.hour, min: next_time_slot.start_time.min)
    end_datetime = new_date.to_datetime.change(hour: next_time_slot.end_time.hour, min: next_time_slot.end_time.min)
    puts "start datetime #{start_datetime}"
    puts "end datetime #{end_datetime}"

    # On instancie 'session' avec cette 'date' le 'start_time' et le 'end_time' de 'slot'
    session = Session.create(start_time: start_datetime, end_time: end_datetime)

    # on calcul sa durée totale ("total_time")
    # on lui assigne les steps du goal(goal.steps) tant que la somme de leur durée est inférieur ou égale au temps total disponible dans un time_slot
    steps = goal.steps.to_a

    steps_total_time = 0
    while steps_total_time <= session.total_time && steps.any?
      step = steps.shift
      step.update(session: session)
      steps_total_time += step.estimated_minute
      puts "step total time: #{steps_total_time}"
    end

    # si il reste des steps alors on cherche le prochain time_slot
    # on prend la valeurs numérique du jour de la session
    # on recherche soit une session le même jour avec un 'start_time' strictement suppérieur au 'start_time'de la session précedente(il vaut mieux utiliser le end_time mais je pense que le start time sera plus simple à manipuer)
    # soit la prochaine session avec un jour strictement suppérieur au jour de la dernière session
    # on calcul le nombre de jour à rajouter afin d'avoir la date correspondante
    # on instancie cette nouvelle date
    # on récupère le start_time et end_time du time_slot trouver
    # on instancie une nouvelle session avec le 'start_time' et le 'end_time' récupéré
    # je pense qu'avec le code que j'ai déjà écrit c'est plus une question de logique d'itérattion, il ne doit pas rester tant de code à ecrire
  end
end


#
