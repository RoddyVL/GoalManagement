class Goal < ApplicationRecord
  belongs_to :user
  has_many :steps, dependent: :destroy
  has_many :time_slots, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :description, presence: true, uniqueness: { scope: :user_id }
end
