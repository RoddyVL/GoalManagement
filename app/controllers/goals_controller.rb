class GoalsController < ApplicationController
  def new
    @goal = Goal.new
  end

  def create
    @goal = Goal.new(goal_params)
    @goal.user = current_user
    if @goal.save
      redirect_to new_goal_step_path(@goal)
    else
      render :new
    end
  end

  private

  def goal_params
    params.require(:goal).permit(:description)
  end
end
