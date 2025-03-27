class SessionsController < ApplicationController
  before_action :set_goal

  def new
    @session = Session.new
  end

  def create
    @session = @goal.sessions.new(session_params)
    if @session.save
      redirect_to calendars_path
    else
      redirect_to goals_path
    end
  end

  private

  def session_params
    params.require(:session).permit(:start_time, :end_time)
  end

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end
end
