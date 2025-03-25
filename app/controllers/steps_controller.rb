class StepsController < ApplicationController
  before_action :set_goal, only: %i[new create]
  before_action :set_step, only: %i[move_up move_down move_up_new move_down_new]
  before_action :set_goals, only: %i[move_up move_down move_up_new move_down_new]

  def new
    @step = Step.new
    @steps = @goal.steps.order(:priority)
  end

  def create
    last_priority = @goal.steps.maximum(:priority) || 0 # Récupérer la dernière priorité
    @step = Step.new(step_params)
    @step.goal = @goal
    @step.priority = last_priority + 1
    if @step.save
      redirect_to request.referer
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
    # Vérifie si la requête vient de Turbo et répond avec un partial
    respond_to do |format|
      format.html { redirect_to new_goal_step_path(@step.goal), notice: "Étape mise à jour avec succès." }
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@step, partial: "steps/step", locals: { step: @step }) }
      format.json { head :no_content }
    end
  else
    render :edit, status: :unprocessable_entity
  end
end



  def destroy
    @step = Step.find(params[:id])
    @step.destroy

    respond_to do |format|
      format.html { redirect_to request.referer || new_goal_step_path(@step.goal) }
      format.turbo_stream do
        # Supprime simplement l'élément de la page
        render turbo_stream: turbo_stream.remove(@step)
      end
    end
  end

  def show
    @step = Step.find(params[:id])
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

  def move_up_new
    previous_step = @step.goal.steps.where("priority < ?", @step.priority).order(priority: :desc).first
    swap_priorities(@step, previous_step) if previous_step
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("steps_new_list", partial: "goals/update_list", locals: { steps: @step.goal.steps.order(:priority), goals: @goals }) }
    end
  end

  def move_down_new
    next_step = @step.goal.steps.where("priority > ?", @step.priority).order(priority: :asc).first
    swap_priorities(@step, next_step) if next_step
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("steps_new_list", partial: "goals/update_list", locals: { steps: @step.goal.steps.order(:priority), goals: @goals }) }
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
    params.require(:step).permit(:description, :estimated_minute, :note)
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
