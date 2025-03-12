class Session < ApplicationRecord
  belongs_to :goal
  has_many :steps

  def total_time
    (end_time - start_time) / 60
  end
end
