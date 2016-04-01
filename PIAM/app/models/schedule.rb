class Schedule < ActiveRecord::Base
  belongs_to :query
  belongs_to :cycle

  def info
    hour, meridian = (initial_time.hour > 12 or (initial_time.hour == 12 and (initial_time.min > 0 or initial_time.sec > 0))) ? [initial_time.hour - 12, :pm] : [initial_time.hour, :am]
    "#{cycle.name} first at: #{initial_time.day}th, #{initial_time.strftime("%B")} of #{initial_time.year} -
     #{initial_time.strftime("%I:%M%p")}"

  end

end
