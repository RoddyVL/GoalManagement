class AddGoalToCalendars < ActiveRecord::Migration[7.1]
  def change
    add_reference :calendars, :goal, null: false, foreign_key: true
  end
end
