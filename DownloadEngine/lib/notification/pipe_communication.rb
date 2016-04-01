require 'rubygems'
require 'json'
require 'notification/assay_notification_class'
require 'notification/compound_notification_class'
require 'notification/count_notification_class'
require 'notification/finished_notification_class'

class PipeCommunication

	def self.write(pipe_write, notification)
    pipe_write.write "notification:\n"
    pipe_write.write "#{notification.class}\n"
    dict = {:cid => notification.cid, :compound_notification => notification.compound_notification, :message => notification.message}
    pipe_write.write "#{JSON.dump(dict)}\n"
  end
	
	def self.read(pipe_read)
		notification_array = pipe_read.read.split(/notification:\n/)
    for i in (1..notification_array.length - 1)
      class_name, data = notification_array[i].split(/\n/)
      dict = JSON.parse(data)
      yield CompoundNotificationClass.new(dict["cid"], dict["compound_notification"], dict["message"])
    end
	end
	
end
