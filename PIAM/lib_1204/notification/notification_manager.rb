require 'notification/sse'

class NotificationManager

  def checkout_notification(observer, channel, last_event_id)
    sse = SSE.new
    options = {:id => ""}
    if observer
      if last_event_id >= 0  #se han perdido datos en la comunicacion
          observer.history.length.times do |i|
            notification = observer.history[i]
            if notification.id > last_event_id
              observer.push(notification)
            elsif notification.id >= last_event_id
              observer.history.delete_at(i)
            end
          end
        end
        if observer.notification?
          notification = observer.get_notification
          observer.push_history(notification)
          notification.message[:channel] = channel
          options[:id] = notification.id
          options[:event] = notification.event
          sse.write(options, notification.message)
          puts sse.content
        else
          sse.write(options, "nothing to show") # un comentario para mantener la comunicacion
        end
	else
      sse.write({:event => 'Stop'}, {:message => "stop", :channel => channel})
    end
    sse.content
  end

end
