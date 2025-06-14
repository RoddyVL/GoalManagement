class CalendarController < ApplicationController
  def index
   # Scope your query to the dates being shown:
   start_date = params.fetch(:start_date, Date.today).to_date

   # For a monthly view:
   @sessions = Session.joins(:goal)
   .where(goals: { user_id: current_user.id })
   .where(start_time: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)


   # Or, for a weekly view:
   # @sessions = Session.where(start_time: start_date.beginning_of_week..start_date.end_of_week)
  end
end
