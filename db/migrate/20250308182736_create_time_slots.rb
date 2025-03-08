class CreateTimeSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :time_slots do |t|
      t.integer :day_of_week
      t.time :start_time
      t.time :end_time
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
