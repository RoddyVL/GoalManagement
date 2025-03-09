class CalendarsController < ApplicationController
  before_action :set_goal

  def index
  end

  private

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end
end
