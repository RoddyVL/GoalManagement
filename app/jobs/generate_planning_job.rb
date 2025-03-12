class GeneratePlanningJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    # récupère l'objectif en fonction de l'id fournit
    goal = Goal.find_by(goal_id)

    # On récupère la date et l'heure à laquelle la méthode est appellé
    method_date_and_time = Time.current

    # On classe les disponibilité par jour et heure dans un ordre croissant
    # On recherche la prochaine disponibilité associé à l'objectif après le jour et l'heure où la méthode est appellé
    next_time_slot = goal.time_slots.order(:day_of_week, :start_time).detect do |time_slot|

      # si la disponibilité est après le jour j ou si c'est le jour jour j mais que l'heure de début est posterieur à l'heure actuelle, on récupère la disponibilté
      if time_slot.day_of_week_before_type_cast > method_date_and_time.wday ||
        (time_slot.day_of_week == method_date_and_time && time_slot.start_time > method_date_and_time.strftime("%H:%M"))
        break time_slot
      end


    # on affiche ce que l'on récupère juste pour tester si tout fonctionne, cette bloc n'est pas indispensable pour que le code fonctionne
    if next_time_slot
      puts "Prochain créneau : #{next_time_slot.day_of_week} de #{next_time_slot.start_time.strftime("%H:%M")} à #{next_time_slot.end_time.strftime("%H:%M")}"
    else
      puts "Aucun créneau disponible dans un futur proche."
    end

    # On récupère la valeurs numérique du jour où la méthode est appellé ainsi que celle de la prochaine disponibilité afin de pouvoir effectuer des calculs dans la suite du code.
    next_time_slot_enum = TimeSlot.day_of_weeks[next_time_slot.day_of_week]
    current_day_of_week = method_date_and_time.wday


    days_until_availability = (next_time_slot_enum - current_day_of_week) % 7
    days_until_availability = 7 if days_until_availability == 0

    next_availability = method_date_and_time + days_until_availability.days
    start_time =  next_time_slot.start_time.strftime('%H:%M')
    end_time = next_time_slot.end_time.strftime('%H:%M')
    next_availability_start = next_availability.change(hour: start_time.split(":")[0].to_i, min: start_time.split(":")[1].to_i)
    next_availability_end = next_availability.change(hour: end_time.split(":")[0].to_i, min: end_time.split(":")[1].to_i)

    puts "#{next_availability_start}"
    puts "#{next_availability_end}"
    puts "Le prochaine disponibilité est le : #{next_availability.strftime('%d/%m/%Y')} de #{next_time_slot.start_time.strftime("%H:%M")} à #{next_time_slot.end_time.strftime("%H:%M")} "

    # à cette date seront rajoutées les heures de début et de fin de ce créneau
    session = Session.create(start_time: next_availability_start, end_time: next_availability_end, goal: goal )

    steps_time = 0
    goal.steps.each do |step|
      steps_time += step.estimated_minute
    end

    puts "#{steps_time}"

    # puis des étapes lui seront assignés tant que la somme de leur durée est inférieure ou égal à la durée totale disponible
    while
      steps_time <= session.total_time
      steps.each do |step|
        step.update(session_id: session.id)

        goal.steps.each do |step|
          steps_time += step.estimated_minute
        end

      end
    end

  end
end

# puis on répétera l'opération jusqu'à ce que toutes les étapes soient planifiées
# une fois arrivé à la fin de la semaine on réitère à partir du 1er jour
# ce planning sera retransmis dans un calendrier
# les étapes du jour seront affichés sous forme de to do list
# si des actions ne sont pas cochées à la fin de la journée tout le planning sera re planifié afin de conserver l'ordre de priorité des actions

# steps = next_time_slot.steps
