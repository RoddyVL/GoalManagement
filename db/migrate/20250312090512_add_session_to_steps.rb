class AddSessionToSteps < ActiveRecord::Migration[7.1]
  def change
    add_reference :steps, :session, null: true, foreign_key: true
  end
end
