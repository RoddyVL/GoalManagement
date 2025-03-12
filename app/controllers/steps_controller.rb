class StepsController < ApplicationController
  before_action :set_goal

  def new
    @step = Step.new
    @steps = @goal.steps
  end

  def create
    @step = Step.new(step_params)
    @step.goal = @goal
    @step.session = @goal.sessions.first
    if @step.save
      redirect_to new_goal_step_path(@goal)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end

  def step_params
    params.require(:step).permit(:description, :estimated_minute)
  end
end
