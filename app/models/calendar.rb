class Calendar < ApplicationRecord
  belongs_to :step
  belongs_to :time_slot
end
