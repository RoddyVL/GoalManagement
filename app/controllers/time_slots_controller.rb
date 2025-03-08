class TimeSlotsController < ApplicationController
  before_action :set_goal
  def new
    @time_slot = TimeSlot.new
    @time_slots = @goal.time_slots
    @time_slots_grouped_by_day = @time_slots.group_by(&:day_of_week)

  end

  def create
    @time_slot = TimeSlot.new(time_slot_params)
    @time_slot.goal = @goal
    if @time_slot.save
      redirect_to new_goal_time_slot_path(@goal)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def generate_calendar
    redirect_to goals_path, notice: "Génération du calendrier en cours..."
  end

  private

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end

  def time_slot_params
    params.require(:time_slot).permit(:day_of_week, :start_time, :end_time)
  end
end
