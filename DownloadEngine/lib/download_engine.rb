require 'pubchem/service_soap'
require 'pubchem/Assay/table_info'
require 'pubchem/Compound/sdf_compound'
require 'pubchem/Substance/sdf_substance'
require 'notification/notification_class'
require 'notification/assay_notification_class'
require 'notification/compound_notification_class'
require 'notification/count_notification_class'
require 'notification/finished_notification_class'
require 'notification/pipe_communication'
require 'extensor/array'
require 'Utilities'
require 'tmpdir'
require 'date'
require 'logger'

class DownloadEngine
  include WebUtilities
  @@coordinate3D = 2
  @@modipCoordinateUnitId = 10
  @@modipCoordinateSourceId = 7
  @@pubChemDataBase = 'pcassay'
  @@sid = "SID"
  @@cid = "CID"
  @@comment = "Comment"
  @@bio_assay_source = "BioAssay_Source"
  # @@number_of_process = `grep -c processor /proc/cpuinfo`.to_i


  #ENV["http_proxy"]
  def initialize(database_server, notify_server, assays_root, download_2d, download_3d, proxy = "")
    @babel_command = "babel"
    @sdf_extension = "sdf"
    @database_server = database_server
    @notify_server = notify_server
    @assays_root = assays_root
    @download_2d = download_2d
    @download_3d = download_3d
    @optional_search = {:webEnv => nil, :queryKey => nil, :useHistory => 'y', :tool => 'ruby', :email => 'modipserver@gmail.com', :field => nil, :reldate => nil, :datetype => 'edat',:retStart => 0, :retMax => 50, :rettype => 'uilist', :sort => nil}
    @assay_info = {:assayColumnType => AssayColumnsType::EAssayColumns_Concise, :listKeyTIDs =>'', :listKeySCIDs => '', :assayFormat => AssayFormatType::EAssayFormat_CSV, :compressType =>  CompressType::ECompress_None, :getVersion => true, :getCounts => true, :getFullDataBlog => false, :formatType => FormatType::EFormat_XML }
    @comp_info = {:format => FormatType::EFormat_SDF, :compress => CompressType::ECompress_None}
    @proxy = proxy
    @service = ServiceSoap.new(@proxy)
    @running = false
    @pids = []
  end

  def logger
    @@logger ||= Logger.new("./log/service.log",'daily')
  end

  def proxy
    @proxy
  end

  def proxy= (other)
    @proxy = other
    @service.proxy = @proxy
  end

  def babel(input, output, input_extension, output_extension)
    #puts "Converting compound: #{input} in 2D to: #{output} in 3D format"
    logger.info("Converting compound: #{input} in 2D to: #{output} in 3D format")

    pid = fork do
      exec("#{@babel_command} -i #{input_extension} #{input} -o #{output_extension} #{output} --gen3D")
    end
    @pids << pid
    Process.wait
    @pids.delete(pid)
  end

  def download(id, query, target, filter = AssayOutcomeFilterType::EAssayOutcome_All, min_date = nil, max_date = nil)
    @running = true
    @thread = Thread.new do
      begin
        @optional_search[:mindate] = min_date
        @optional_search[:maxdate] = max_date
        interval = @optional_search[:retMax]
        assay_result = @service.eSearch(@@pubChemDataBase, query, @optional_search)
        total = assay_result.Count
        notify(CountNotificationClass.new(id, total, "AssayCount", "total assay #{total}"))
        assay_process(id, target, assay_result, filter) do |aid, table_info|
          notify(CountNotificationClass.new(id, table_info.length, "CompoundCount", "total compound #{table_info.length}"))
          child_process(id, table_info, aid)
        end
        if total > interval
          @optional_search[:webEnv] =  assay_result.webEnv
          @optional_search[:queryKey] =  assay_result.queryKey
          iterator = total / interval
          for i in (1..iterator)
            @optional_search[:retStart] = i * @optional_search[:retMax]
            assay_result = @service.eSearch(@@pubChemDataBase, query, @optional_search)
            assay_process(id, target, assay_result, filter) do |aid, table_info|
              notify(CountNotificationClass.new(id, table_info.length, "CompoundCount", "total compound #{table_info.length}"))
              child_process(id, table_info, aid)
            end
          end
        end
        notify(FinishedNotificationClass.new(id, Time.now, "download complete"))
      rescue Exception => e
        notify(FinishedNotificationClass.new(id, Time.now, "download error, details:\n#{e.message}", "Stop"))
      end
      @running = false
    end
  end

  def assay_process(id, target, assay_result, assay_filter)
    assay_result.ids.each do |aid|
      aid = aid.to_s
      result, assay_path = @database_server.checkout_assay(aid)
      table_info = nil
      if result == 1 #esta siendo procesado
        notify(AssayNotificationClass.new(id, aid, "AssayProcessed", "the assay #{aid} is being processed by another process"))
        next
      elsif result == 0  #el ensayo no ha sido insertado en la base de datos
        @aid = aid
        assay_description = nil
        column_description = nil
        begin
          assay_description = @service.GetAssayDescription(aid, @assay_info[:getVersion], @assay_info[:getCounts], @assay_info[:getFullDataBlog], @assay_info[:formatType]).assayDescription
        rescue Exception => e
          leave_resource(:assay)
          notify(AssayNotificationClass.new(id, aid, "AssayFailed", "assay #{aid} download description error, details:\n#{e.message}"))
          next
        end
        begin
          column_description = @service.get_column_descriptions(aid)
        rescue Exception => e
          leave_resource(:assay)
          notify(AssayNotificationClass.new(id, aid, "AssayFailed", "assay #{aid} download column description error, details:\n#{e.message}"))
          next
        end
        begin
          assay_url = @service.GetAssayUrl(aid, @assay_info[:assayColumnType], @assay_info[:assayFormat], @assay_info[:compressType], assay_filter)
          table_info = get_table_info(assay_url, aid)
        rescue Exception => e
          leave_resource(:assay)
          notify(AssayNotificationClass.new(id, aid, "AssayFailed", "assay #{aid} download compound information error, details:\n#{e.message}"))
          next
        end
        @database_server.insert_assay(aid, target, assay_description, column_description, table_info.path)
        leave_resource(:assay)
        notify(AssayNotificationClass.new(id, aid, "AssayInserted", "assay #{aid} was inserted"))
      else #el ensayo esta en la base de datos
        table_info = TableInfo.new(assay_path)
        notify(AssayNotificationClass.new(id, aid, "AssayProcessed", "assay #{aid} was processed"))
      end
      yield [aid, table_info]
    end
  end

  def child_process(id, table_info, aid)
    table_header = table_info.header
    compound_process(id, table_info, table_header) do |cid, row|
      @database_server.checkout_assay_compound(aid, cid, row, table_header)
    end
  end

  def compound_process(id, table_info, table_header)
    table_info.values() do |row|
      begin
        cid = row[table_header[@@cid]]
        result = @database_server.checkout_compound(cid)
        if result == 1  #esta siendo procesado
          notify(CompoundNotificationClass.new(id, cid, "CompoundProcessed", "the compound #{cid} is being processed by another process"))
          next
        elsif result == 0 #el compuesto no ha sido insertado en la base de datos
          @cid = cid
          cmp = nil
          cmp2d = nil

          begin #descarga del compuesto en 3d
            cmp = get_compound(@service.GetSCIDUrl(@service.InputListText(cid), @comp_info), cid)
            #cmp = get_compound(get_download_url(cid,@sdf_extension), cid+".#{@sdf_extension}") #REST interface
          rescue Exception => e
            cmp = nil
            notify(CompoundNotificationClass.new(id, cid, "CompoundWarning", "error downloading compound: #{cid} in 3d, details:\n#{e.message}"))
          end

          begin #descarga del compuesto en 2d
            cmp2d = get_compound(@service.GetSCIDUrl(@service.InputListText(cid), @comp_info, false), cid)
            #cmp2d = get_compound(get_download_url(cid,@sdf_extension,false), cid+".#{@sdf_extension}") #REST interface

            if cmp == nil
              cmp = cmp2d
            else
              cmp.copy_missing_data(cmp2d)
            end

            if cmp.name =~ /.*;.*/
              notify(CompoundNotificationClass.new(id, cid, "CompoundFailed", "compound: #{cid} descarted because it has more than one molecule"))
              return
            end

            if cmp.molecular_formula.length > 0
              mf = cmp.molecular_formula

              if matches = mf.upcase.match(/.*(?<Boron>B\w{1}).*/)
                logger.info("Molecular formula to process #{mf}. Pattern matched: #{matches['Boron']}\n")
                if matches['Boron'] != 'BR'
                  notify(CompoundNotificationClass.new(id, cid, "CompoundFailed", "compound: #{cid} descarted because it contains Boron elements"))
                  return
                end
              end
            end

          rescue Exception => e1
            leave_resource(:compound)
            notify(CompoundNotificationClass.new(id, cid, "CompoundWarning", "error downloading compound: #{cid} in 2d, details:\n#{e1.message}"),
                   CompoundNotificationClass.new(id, cid, "CompoundFailed", "error downloading compound: #{cid}"))
            next
          end

          directory = cmp.is_3d ? File.join(@download_3d, cmp.filename) : File.join(@download_2d, cmp.filename)
          f =  File.new(directory, 'w')
          f.puts cmp.to_s
          f.close

          cmp.path = directory

          if !cmp.is_3d
            input = File.join(@download_2d, cmp.filename)
            output = File.join(@download_3d, cmp.filename)

            babel(input,output,@sdf_extension,@sdf_extension)

            if File.file?(output)
              cmp.set_3d_coordinate(@@coordinate3D)
              cmp.set_coordinate_source(@@modipCoordinateSourceId)
              cmp.set_coordinate_unit(@@modipCoordinateUnitId)
              cmp.path = output
            end
          end

          insert_type = cmp.is_3d ? '3D' : '2D'
          directory = cmp.path

              @database_server.insert_compound(cmp)
          leave_resource(:compound)
          notify(CompoundNotificationClass.new(id, cid, "CompoundInserted", "compound #{cid} was inserted in #{insert_type}. Locate at: #{directory}"))
        else
          notify(CompoundNotificationClass.new(id, cid, "CompoundProcessed", "compound #{cid} was processed"))
        end
        yield [cid, row]
      rescue Exception => e
        leave_resource(:compound) if @cid
        notify(CompoundNotificationClass.new(id, cid, "CompoundFailed", "unexpected error processing the compound: #{cid}, details:\n#{e.message}"))
        next
      end
    end
  end

  def leave_resource(key)
    if key == :assay
      @database_server.leave_resource(key, @aid)
      @aid = nil
    else
      @database_server.leave_resource(key, @cid)
      @cid = nil
    end
  end

  def notify(*arg)
    @notify_server.notify(*arg)

    arg.each do |obj|
      logger.info("[#{obj.query_id}: #{obj.event}] #{obj.message}")
    end
  end

  def stop()
    @thread.kill if @thread and @thread.alive?
    if is_running
      if @aid
        unless @database_server.assay_find_by_aid(@aid)
          Dir[File.join(@assays_root, @aid + ".*")].each do |entry|
            File.delete(entry)
          end
        end
        leave_resource(:assay)
      end
      if @cid
        Dir[File.join(Dir.tmpdir, @cid + ".*")].each do |entry|
          File.delete(entry)
        end
        unless @database_server.compound_find_by_cid(@cid)
          Dir[File.join(@download_3d, @cid + ".*")].each do |entry|
            File.delete(entry)
          end
          Dir[File.join(@download_2d, @cid + ".*")].each do |entry|
            File.delete(entry)
          end
        end
        leave_resource(:compound)
      end
      @running = false
    end
  end

  def get_table_info(url, filename)
    dir = File.join(@assays_root, filename + '.' + url.split('.').last)
    #WebUtilities.FTPRequest(url, dir)
    WebUtilities.HTTPRequest(url, dir, @proxy)
    TableInfo.new(dir)
  end

  def get_compound(url, filename)
    filename = filename + '.' + url.split('.').last #comment this line on REST interface
    dir = File.join(Dir.tmpdir, filename)
    #WebUtilities.FTPRequest(url, dir)
    #puts "Downloading compound: #{filename} from: #{url}"
    logger.info("Downloading compound: #{filename} from: #{url}")

    WebUtilities.HTTPRequest(url, dir, @proxy)
    compound = nil
    case(@comp_info[:format])
      when FormatType::EFormat_SDF
        compound = SDFCompound.new(dir, filename)
    end
    File.delete(dir)
    return compound
  end

  def get_download_url(cid,format,is_3d = true)
    record_type = is_3d ? '3d' : '2d'
    return "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{cid}/record/#{format}/?record_type=#{record_type}"
  end

  def is_running
    @running
  end

end