class GoalsController < ApplicationController
  before_action :set_goal_and_steps, only: %i[show edit reassign]

  def new
    @goal = Goal.new
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

  def index
    @current_day = Date.current
    @goals = current_user.goals
    @sessions = @goals.flat_map(&:sessions)
     # Vérifier si on a des sessions avant de filtrer
    @today_sessions = @sessions.select { |session| session.start_time&.to_date == @current_day }
    @steps =  @today_sessions.flat_map { |session| session.steps.order(:id) }
  end

  def show
    @time_slots = @goal.time_slots
  end

  def toggle_status
    @step = Step.find(params[:id])
    if @step.update(status: params[:status])
      render json: { message: 'Statut mis à jour avec succès.' }, status: :ok
    else
      render json: { error: 'Erreur lors de la mise à jour du statut.' }, status: :unprocessable_entity
    end
  end



  def edit
    @step = Step.new
  end

  def reassign
    ReassignAfterUpdateJob.perform_now(@goal.id)
    redirect_to goals_path
  end

  private

  def set_goal_and_steps
    @goal = current_user.goals.find(params[:id])
    @steps = @goal.steps.order(:priority)
  end

  def goal_params
    params.require(:goal).permit(:description)
  end
end
