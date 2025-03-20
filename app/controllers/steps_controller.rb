class StepsController < ApplicationController
  before_action :set_goal, only: %i[new create]
  before_action :set_step, only: %i[move_up move_down]
  before_action :set_goals, only: %i[move_up move_down]

  def index
    @goals = current_user.goals
    @steps = @goals.flat_map(&:steps).sort_by(&:priority)
  end

  def new
    @step = Step.new
    @steps = @goal.steps.order(:priority)
  end

  def create
    last_priority = @goal.steps.maximum(:priority) || 0 # Récupérer la dernière priorité
    @step = Step.new(step_params)
    @step.goal = @goal
    @step.session = @goal.sessions.first
    @step.priority = last_priority + 1
    if @step.save
      redirect_to new_goal_step_path(@goal)
    else
      @steps = @goal.steps.order(:priority)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @step = Step.find(params[:id])
  end

  def update
    @step = Step.find(params[:id])
    if @step.update(step_params)
      redirect_to new_goal_step_path(@step.goal), notice: "Étape mise à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @step = Step.find(params[:id])
    @step.destroy
    redirect_to new_goal_step_path(@step.goal), notice: "Étape supprimée avec succès."
  end


  def toggle_status
    @step = Step.find(params[:id])
    if @step.update(status: params[:status])
      render json: { message: 'Statut mis à jour avec succès.' }, status: :ok
    else
      render json: { error: 'Erreur lors de la mise à jour du statut.' }, status: :unprocessable_entity
    end
  end

  def move_up
    previous_step = @step.goal.steps.where("priority < ?", @step.priority).order(priority: :desc).first
    swap_priorities(@step, previous_step) if previous_step
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("steps_list", partial: "steps/list", locals: { steps: @step.goal.steps.order(:priority), goals: @goals }) }
    end
  end

  def move_down
    next_step = @step.goal.steps.where("priority > ?", @step.priority).order(priority: :asc).first
    swap_priorities(@step, next_step) if next_step
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("steps_list", partial: "steps/list", locals: { steps: @step.goal.steps.order(:priority), goals: @goals }) }
    end
  end

  private

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end

  def set_goals
    @goals = current_user.goals
  end

  def step_params
    params.require(:step).permit(:description, :estimated_minute)
  end

  def swap_priorities(step1, step2)
    step1.priority, step2.priority = step2.priority, step1.priority
    step1.save!
    step2.save!
  end

  def set_step
    @step = Step.find(params[:id])
  end
end
