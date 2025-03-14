class GoalsController < ApplicationController
  def new
    @goal = Goal.new
  end

  def index
    @goals = current_user.goals
    @current_day = Date.current

    @sessions = @goals.flat_map(&:sessions)
     # Vérifier si on a des sessions avant de filtrer
    @today_sessions = @sessions.select { |session| session.start_time&.to_date == @current_day }
    # @steps = @today_sessions.flat_map(&:steps)
    @steps = Step.all
  end

  def create
    @goal = Goal.new(goal_params)
    @goal.user = current_user
    if @goal.save
      session = Session.create(goal: @goal)
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
