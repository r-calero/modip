class Cycle < ActiveRecord::Base
  has_many :schedules
  has_many :queries, :through => :schedules
  
  def sec2dhms(secs)
    time = secs.round          # Get rid of microseconds
    sec = time % 60            # Extract seconds
    time /= 60                 # Get rid of seconds
    mins = time % 60           # Extract minutes
    time /= 60                 # Get rid of minutes
    hrs = time % 24            # Extract hours
    time /= 24                 # Get rid of hours
    days = time                # Days (final remainder)
    [days, hrs, mins, sec]     # Return array [d,h,m,s]
  end
  
end
