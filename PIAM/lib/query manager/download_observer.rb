require_relative '../notification/user_observer'

class DownloadObserver < UserObserver
  @@queue_size = 512

  def initialize(query_id, notify_server)
    super(query_id, notify_server)
    @process = notify_server.get_process(@id)
    @last_id = Notification.where(:query_id => @id).maximum(:id)
    @remaining_notification = 0
    @compound_inserted = []
  end

  def update(*notifications)
    notifications.each do |notification|
      if notification.query_id == @id
        element = UserNotification.new(notification.event)
        hash = {:message => notification.message}
        notification_model = Notification.new(:message => notification.message, :query_id => @id, :event => notification.event)
        if notification.class == FinishedNotificationClass
          FinishedNotification.create(:notification => notification_model, :time => Time.now)
          stop_listen()
          send_notification()
        else
          if notification.class == AssayNotificationClass
            hash[:aid] = notification.aid
            AssayNotification.create(:notification => notification_model, :aid => notification.aid, :assay_notification_type => AssayNotificationType.find_by_name(notification.event))
          elsif notification.class == CompoundNotificationClass
            hash[:cid] = notification.cid
            compound_notification_type = CompoundNotificationType.find_by_name(notification.event)
            @compound_inserted << notification.cid if compound_notification_type.is_compound_inserted
            CompoundNotification.create(:notification => notification_model, :cid => notification.cid, :compound_notification_type => compound_notification_type)
          elsif notification.class == CountNotificationClass
            hash[:total] = notification.total
            CountNotification.create(:notification => notification_model, :total => notification.total, :element_count => notification.event)
          end
        end
        if @notifications.length < @@queue_size
          element.message = hash
          element.id = notification_model.id
          @notifications << element
        else
          @remaining_notification += 1
        end
         #logger.info "Observer: #{@id} recive notification:\n #{element.event} \n #{element.id} \n #{element.message}"
      end
    end
  end

  def notification?
    result = @notifications.any?
    if !result and @remaining_notification > 0
      arr = Notification.where(["query_id = ? and id > ?", @id, @last_id]).order("id DESC").limit(@@queue_size)
      @remaining_notification -= arr.length
      result = true
      arr.each do |n|
        element = UserNotification.new(n.event)
        hash = {:message => n.message}
        if n.compound_notification
          hash[:cid] = n.compound_notification.cid
        elsif n.assay_notification
          hash[:aid] = n.assay_notification.aid
        elsif n.count_notification
          hash[:total] = n.count_notification.total
        else #"FinishedNotification"
          #ignore
        end
        element.message = hash
        element.id = n.id
        @notifications << element
      end
    end
    result
  end

  def get_notification
   note = @notifications.delete_at(0)
   @last_id = note.id
   update_process(note)
   note
  end

  def push(notification)
    @notifications.insert(0, notification)
    update_process(notification, method(:backward))
  end

  def push_history(notification)
    @history.insert(0, notification)
  end

  def process_assays
    @process[:process_assays].to_s
  end

  def process_compounds
    @process[:process_compounds].to_s
  end

  def total_assays
    if @process[:total_assays]
      @process[:total_assays].to_s
    else
      'unknown'
    end
  end

  def total_compounds
    if @process[:total_compounds]
      @process[:total_compounds].to_s
    else
      'unknown'
    end
  end

  def start()
    @notify_server.add_observer(self)
    @listen = true
    @process = {:process_assays => 0, :process_compounds => 0}
    @last_id = Notification.where(:query_id => @id).maximum(:id)
    @notifications = []
    @history = []
    @compound_inserted = ["66541"]
  end

  def stop()
    if @listen
      stop_listen()
      send_notification()
    end

  end

  def send_notification()
   if @compound_inserted.size > 0
  	query = Query.find(@id)
  	target = query.target
  	# calculate docking ranking
  	Thread.new do
  	  docking_server = PIAM::Application::DOCKING_MANAGER
  	  ((@compound_inserted.size / 50) + 1).times do |i|
  		  cids = @compound_inserted[i * 50..((i+1)*50 - 1)]
  		  #compounds = Compound.find_all_by_cid(cids)
  		  docking_server.start_background_docking(query.user.id, target.id, cids)
  	  end
  	  order_hash = {}
  	  Compound.sort_by_energy_range(target, 3, 1, 2).each_with_index do |item, index|
  		  order_hash[index + 1] = item if @compound_inserted.include?(item[0])
  	  end
  	  Notifier.docking_compound(query.user.emails, order_hash, query.query, 3, 2, 1).deliver
  	end

   end

  end

  private

  def update_process(note, func = method(:forward))
    if note.event == 'assay_count'
      @process[:total_assays] ||= note.message[:total]
      @process[:process_compounds] = (func.name == "forward") ? 0 : @process[:total_compounds]
    elsif note.event == 'assay_failed' || note.event == 'assay_process'
      @process[:process_assays] = func.call(@process[:process_assays])
    elsif note.event == 'compound_count'
      @process[:total_compounds] ||= note.message[:total]
    elsif note.event == 'inserted_compound' or note.event == 'compound_failed' or note.event == 'compound_process'
      @process[:process_compounds] = func.call(@process[:process_compounds])
    end
  end

  def forward(process)
    process + 1
  end

  def backward(process)
    process - 1
  end

end

