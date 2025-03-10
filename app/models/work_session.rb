class WorkSession < ApplicationRecord
  belongs_to :goal
  belongs_to :step
  belongs_to :time_slot
end
