class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.references :goal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
