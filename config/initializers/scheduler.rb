# Rails.application.config.after_initialize do
#   if Rails.env.production? || Rails.env.development?
#     ReassignStepsJob.set(wait_until: Time.current.beginning_of_day + 1.day).perform_later
#   end
# end
