class CreateSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :steps do |t|
      t.string :description
      t.integer :estimated_minute
      t.integer :status, default: 0
      t.integer :priority
      t.references :goal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
