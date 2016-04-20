#require 'schema'
require 'rubygems'
require 'download_engine'
require 'docking'
require 'drb'
require 'drb/observer'
require 'socket'

class DownloadServer
  include DRb::DRbObservable

  def initialize(process_number, proxy, assays_root, compound_2d_root, compound_3d_root, pid_root)
    @process_number = process_number
    @proxy = proxy
    @assays_root = assays_root
    @compound_2d_root = compound_2d_root
    @compound_3d_root = compound_3d_root
    @pid_root = File.join(pid_root, "pid")
    @pids = []
    @check_out = {}
    @download_engines = {}
    @workers = {}
    @process = {}
    File.open(@pid_root, 'w') do |f|
      f.puts Process.pid
    end
    DRb.start_service
    @database_server = DRbObject.new(nil, "druby://localhost:9001")
    # Create a socket, bind it to localhost:4242, and start listening.
    # Runs once in the parent; all forked children inherit the socket's
    # file descriptor.
    @acceptor = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    @address = Socket.pack_sockaddr_in(4242, '0.0.0.0')
    @acceptor.bind(@address)
    @acceptor.listen(10)


    # The trap is guaranteed to happen, and guaranteed to happen only
    # once, right before the process exits for any reason (unless
    # it's terminated with a SIGKILL).
    trap('EXIT') { @acceptor.close() }

    # Fork you some child processes. In the parent, the call to fork
    # returns immediately with the pid of the child process; fork never
    # returns in the child because we exit at the end of the block.
    @process_number.times do
      @pids << create_process()
    end

  end

  def start_download(id, query, target, filter, min_date, max_date)
    begin
      @download_engines[id] ||= DownloadEngine.new(@database_server, self, @assays_root, @compound_2d_root, @compound_3d_root, @proxy)
      @process[id] = {:process_assays => 0, :process_compounds => 0, :total_assays => 0, :total_compounds => 0}
      if @workers.size < @process_number
        params = ParamsDump.new(id, query, target, filter, min_date, max_date)
        socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
        socket.connect(@address)
        socket.puts Marshal.dump(params)
        @workers[id] = socket.readline.chomp.to_i
        socket.close
      else
        puts "#{id}: #{query} :#{target} config:#{min_date}- #{max_date}- #{filter}"
        puts "process #$$ executing download proxy: #{@download_engines[id].proxy.empty? ? 'nil' : @download_engines[id].proxy}"
        @download_engines[id].download(id, query, target, filter, min_date, max_date)
      end
      true
    rescue Exception => e
      puts e.message
      @download_engines.delete(id)
      @process.delete(id)
      false
    end

  end

  def stop_download(id)
    download = @download_engines[id]
    if download
      download.stop()
      @workers.delete(id) if @workers[id]
      puts "stopped download #{id}"
      true
    else
      puts "download not exist"
      false
    end

  end

  def destroy(id)
    download = @download_engines[id]
    if download
      download.stop() if download.is_running
      @workers.delete(id) if @workers[id]
      @download_engines.delete(id)
    end
  end

  def get_download_engine(id)
    @download_engines[id]
  end

  def downloading(id)
    @download_engines[id] and @download_engines[id].is_running ? true :false
  end

  def get_process(id)
    @process[id]
  end

  #Use only from provide management script
  def set_proxy(proxy)
    @download_engines.values.each do |d|
      d.proxy = proxy
    end
  end

  def notify(*args)
    args.each do |notification|
     if notification.class == AssayNotificationClass and (notification.event == "AssayInserted" or notification.event == "AssayFailed")
       @process[notification.query_id][:process_assays] += 1
     elsif notification.class == CompoundNotificationClass and notification.event != "CompoundWarning"
       @process[notification.query_id][:process_compounds] += 1
     elsif notification.class == CountNotificationClass
       if notification.event == "AssayCount"
      @process[notification.query_id][:total_assays] = notification.total
     else
        @process[notification.query_id][:total_compounds] = notification.total
       end
     elsif notification.class == FinishedNotificationClass
       puts "finished #{notification.query_id}"
       @process.delete(notification.query_id)
       @workers.delete(notification.query_id) if @workers[notification.query_id]
     end
    puts notification.message
    end
    changed
    notify_observers(*args)
  end

  def shutdown()
    @download_engines.values.each do |download|
      download.stop()
    end

  end

  def data_download(path)
  file = File.open(path, 'r')
  result = file.readlines
  file.close()
  result
  end

  class ParamsDump
    attr_reader :query_id, :query, :target, :filter, :min_date, :max_date

    def initialize(id, query, target, filter, min_date, max_date)
      @query_id = id
      @query = query
      @target = target
      @filter = filter
      @min_date = min_date
      @max_date = max_date
    end

    def marshal_dump
      {:i => @query_id,:q => @query, :t => @target, :f => @filter, :min => @min_date, :max => @max_date}
    end

    def marshal_load(when_dumped)
      @query_id = when_dumped[:i]
      @query = when_dumped[:q]
      @target = when_dumped[:t]
      @proxy = when_dumped[:p]
      @root = when_dumped[:r]
      @filter = when_dumped[:f]
      @min_date = when_dumped[:min]
      @max_date = when_dumped[:max]
    end

  end

  private

  def create_process
    fork do
      server = nil
      download = nil
      # now we're in the child process; trap (Ctrl-C) interrupts and
      # exit immediately instead of dumping stack to stderr.
      trap('INT') { exit }

      # stopped de underlying download (it's terminated with a SIGKILL)
      trap("TERM") do
        if download and download.is_running
          puts "stop download: #{@params.query_id}"
          download.stop
        end
        exit
      end

      puts "child #$$ accepting on shared socket (localhost:4242)"

      loop {
        # This is where the magic happens. accept(2) blocks until a
        # new connection is ready to be dequeued.
        socket, _ = @acceptor.accept
        unless server
          server = DRbObject.new(nil, "druby://localhost:1989")
        end
        @params = Marshal.load(socket.readline.chomp)
        download = server.get_download_engine(@params.query_id)
        puts "#{@params.query_id}: #{@params.query} :#{@params.target} config:#{@params.min_date}- #{@params.max_date}- #{@params.filter}"
        socket.puts $$
        socket.close
        puts "process #$$ executing download proxy: #{download.proxy.empty? ? 'nil' : download.proxy}"
        download.download(@params.query_id, @params.query, @params.target)
      }
      exit
    end
  end

end

tmp = "tmp"
data = "data"
assays = File.join(data, "Assays")
compounds = File.join(data, "Compounds")
compound_2d = File.join(compounds, "2D")
compound_3d = File.join(compounds, "3D")
pids = File.join(tmp, 'pids')

Dir.mkdir(tmp) unless File.exist?(tmp)
Dir.mkdir(pids) unless File.exist?(pids)
Dir.mkdir(compounds) unless File.exist?(compounds)
Dir.mkdir(assays) unless File.exist?(assays)
Dir.mkdir(compound_2d) unless File.exist?(compound_2d)
Dir.mkdir(compound_3d) unless File.exist?(compound_3d)

process_number = ARGV[0] ? ARGV[0].to_i : 0;
proxy = ENV["MODIP_PROXY"] ? ENV["MODIP_PROXY"] : ARGV[1].to_s
download_server = DownloadServer.new(process_number, proxy, assays, compound_2d, compound_3d, pids)


trap("INT") do
  puts 'Stopping ...'
  File.delete(File.join(pids, "pid"))
  download_server.shutdown()
  puts "Exiting"
  exit
end

trap("TERM") do
  puts 'Stopping ...'
  File.delete(File.join(pids, "pid"))
  download_server.shutdown()
  puts "Exiting"
  exit
end


DRb.start_service('druby://localhost:1989', download_server)
puts DRb.uri
DRb.thread.join
