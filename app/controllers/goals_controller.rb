class GoalsController < ApplicationController
  def new
    @goal = Goal.new
  end

  def index
    @current_day = Date.current
    @goals = current_user.goals
    @sessions = @goals.flat_map(&:sessions)   # @goals.flat_map { |goal| goal.sessions }
     # Vérifier si on a des sessions avant de filtrer
    @today_sessions = @sessions.select { |session| session.start_time&.to_date == @current_day }
    # @steps = @today_sessions.steps
    @steps =  @today_sessions.flat_map { |session| session.steps.order(:id) }
  end

  def toggle_status
    @step = Step.find(params[:id])
    if @step.update(status: params[:status])
      render json: { message: 'Statut mis à jour avec succès.' }, status: :ok
    else
      render json: { error: 'Erreur lors de la mise à jour du statut.' }, status: :unprocessable_entity
    end
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
