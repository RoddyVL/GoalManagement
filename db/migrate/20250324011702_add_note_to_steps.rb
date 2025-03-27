class AddNoteToSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :steps, :note, :text
  end
end
