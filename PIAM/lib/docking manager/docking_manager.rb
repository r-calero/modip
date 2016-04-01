require 'drb'
require_relative 'docking_observer'
require_relative '../notification/notification_manager'

class DockingManager < NotificationManager
  
  def initialize()
    @server = DRbObject.new(nil, "druby://localhost:1992")
    @observer = {}
    super()
  end

  def get_notification(user_id, target_id, last_event_id)
    channel = make_key(user_id, target_id)
    observer = @observer[channel]
    checkout_notification(observer, channel, last_event_id)
  end

  def is_docking(user_id, target_id)
    channel = make_key(user_id, target_id)
    @server.is_docking(channel)

  end

  def get_process(user_id, target_id)
    channel = make_key(user_id, target_id)
    observer = @observer[channel]
    [observer.process, observer.total]
  end

  def start_docking(user_id, target, compound_docking)
  	DRb.start_service
    key = make_key(user_id, target.id)
    observer = DockingObserver.new(key, @server, compound_docking[:total])
    observer.start()
    @observer[key] = observer
    Thread.new do
        if compound_docking[:all]
			pages = compound_docking[:total] / 50
			pages.times do |page|
				compounds = Compound.page(page).per(50)
				@server.start_docking(key, target, compounds, true)
			end
        else
			compound_docking[:pages].each do |page|
				compounds = Compound._3d.order("cid+0").page(page.to_i - 1).per(50)
				@server.start_docking(key, target, compounds, true)
			end
			iterations = (compound_docking[:cids].length / 50) + 1
			iterations.times do |i|
				compounds = Compound.find_all_by_cid(compound_docking[:cids][(i * 50)..(i+1)*50 -1])
				@server.start_docking(key, target, compounds, true)
			end
		end
    end
  end
  
  def start_background_docking(user_id, target, compounds)
	DRb.start_service
	key = make_key(user_id, target.id)
	@server.start_docking(key, target, compounds, true)
  end
  
  def stop_docking(user_id, target_id)
  	key = make_key(user_id, target_id)
  	observer = @observer[key]
  	observer.stop()
  	@server.stop_docking(key)
  end
  
  def get_resource(resource)   
	@server.get_resource(resource)
  end

  def upload_file(target, file, data)
    @server.upload_file(target, file, data)
  end

  def create_target_dir(target_name)
    @server.create_target_dir(target_name)
  end

  def delete_receptor(receptor_path)
    @server.delete_receptor(receptor_path)
  end

  def make_key(*args)
    result  = ""
    args.each do |arg|
      result += "#{arg}"
    end
    result
  end

end
