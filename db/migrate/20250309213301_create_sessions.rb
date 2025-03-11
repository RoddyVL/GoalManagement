  class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.integer :day_of_week
      t.time :start_time
      t.time :end_time
      t.string :description
      t.integer :estimated_minute
      t.integer :status, default: 0, null: false
      t.integer :priority
      t.references :goal, null: false, foreign_key: true
      t.references :step, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true

      t.timestamps
    end
  end
end
