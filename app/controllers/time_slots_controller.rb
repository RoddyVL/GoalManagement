class TimeSlotsController < ApplicationController
  before_action :set_goal
  def new
    @time_slot = TimeSlot.new
    @time_slots = @goal.time_slots.order(:day_of_week)
    @all_time_slots = TimeSlot.where(goal: current_user.goals).where.not(goal: @goal).order(:day_of_week)
  end

  def create
    @time_slot = TimeSlot.new(time_slot_params)
    @time_slot.goal = @goal
    if @time_slot.save
      redirect_to request.referer
    else
      @time_slots = TimeSlot.all.order(:day_of_week, :start_time) # On récupère à nouveau la variable pour la passer à la vue lors du render
      flash.now[:alert] = @time_slot.errors.full_messages.to_sentence
      render :new, notice: "créneaux déjà pris"
    end
  end

  def destroy
    @time_slot = TimeSlot.find(params[:id])
    @time_slot.destroy

    respond_to do |format|
      format.html { redirect_to request.referer || new_goal_time_slot_path(@goal) }
      format.turbo_stream do
        # Supprime simplement l'élément de la page
        render turbo_stream: turbo_stream.remove(@time_slot)
      end
    end
  end

  def index
    @all_time_slots = TimeSlot.where(goal: current_user.goals).where.not(goal: @goal).order(:day_of_week)
    @time_slots = @goal.time_slots.order(:start_time)
    @time_slot = TimeSlot.new
  end

  def generate_calendar
   GeneratePlanningJob.perform_now(@goal.id)
    redirect_to calendars_path, notice: "Génération du calendrier en cours..."
  end

  def redefine_slots
    RedefineSlotsJob.perform_now(@goal.id)
    redirect_to goals_path
  end

  def destroy_all
    @goal.time_slots.destroy_all
    respond_to do |format|
      format.html { redirect_to goal_path(@goal), notice: "Tous les créneaux horaires ont été supprimés avec succès." }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("time_slots") }
    end
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:goal_id])
  end

  def time_slot_params
    params.require(:time_slot).permit(:day_of_week, :start_time, :end_time)
  end
end
