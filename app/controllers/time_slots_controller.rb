class TimeSlotsController < ApplicationController
  before_action :set_goal
  def new
    @time_slot = TimeSlot.new
    @time_slots = TimeSlot.all.order(:day_of_week, :start_time)
  end

  def create
    @time_slot = TimeSlot.new(time_slot_params)
    @time_slot.goal = @goal
    if @time_slot.save
      redirect_to new_goal_time_slot_path(@goal)
    else
      @time_slots = TimeSlot.all.order(:day_of_week, :start_time) # Réassigner @time_slots
      flash.now[:alert] = @time_slot.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def generate_calendar
    ReassignStepsJob.perform_now(@goal.id)
    redirect_to calendars_path, notice: "Génération du calendrier en cours..."
  end

  private

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end

  def time_slot_params
    params.require(:time_slot).permit(:day_of_week, :start_time, :end_time)
  end
end
