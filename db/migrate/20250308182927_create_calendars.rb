class CreateCalendars < ActiveRecord::Migration[7.1]
  def change
    create_table :calendars do |t|
      t.references :step, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true

      t.timestamps
    end
  end
end
