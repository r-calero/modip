require 'cgi'
require 'entrez'
require 'uri'
require 'pubchem/service/defaultDriver'


class ServiceSoap

  attr_reader :proxy

  def initialize(proxy = "", attempt = 10)
    @proxy = proxy.to_s
    @attempt = attempt
    @pug_soap_service = PUGSoap.new()
    unless @proxy.empty?
      begin
        @pug_soap_service.httpproxy = @proxy
        uri = URI.parse(@proxy)
        Entrez.proxy(uri.host, uri.port, uri.user, uri.password)
      rescue Exception => e

      end
    end


  end

  def proxy
    return @proxy

  end

  def proxy= (other)
    @proxy = other.to_s
    unless @proxy.empty?
      begin
         @pug_soap_service.httpproxy = @proxy
        uri = URI.parse(@proxy)
        Entrez.proxy(uri.host, uri.port, uri.user, uri.password)
      rescue Exception => e

      end
    end

  end

  def eSearch(db, term, opt)
     query = query_term(term)
     response = Entrez.ESearch(db, query, opt)
     return response
  end

  def GetAssayUrl(aid, assayColumnType, assayFormat, compressType, assayOutcomeFilterType = nil, listKeyTIDs = nil, listKeySCIDs = nil)
      assayKey =  @pug_soap_service.inputAssay(InputAssay.new(aid, assayColumnType, listKeyTIDs, listKeySCIDs, assayOutcomeFilterType))
      dwlKey = @pug_soap_service.assayDownload(AssayDownload.new(assayKey.assayKey, assayFormat, compressType))
      status, details = download_status(dwlKey.downloadKey)
      if status
        return GetUrl(dwlKey.downloadKey)
      else
        raise Exception.new(details)
      end
  end

  def GetSCIDUrl(listKey, compInfo, use3D = true)
    dwlKey = @pug_soap_service.download(Download.new(listKey, compInfo[:format], compInfo[:compress], use3D))
    status, details = download_status(dwlKey.downloadKey)
    if status
      return GetUrl(dwlKey.downloadKey)
    else
      raise Exception.new(details)
    end
  end

  def GetAssayDescription(aid, getVersion, getCounts, getFullDataBlog, formatType)
    index = 1
    loop do
      begin
        return @pug_soap_service.getAssayDescription(GetAssayDescription.new(aid, getVersion, getCounts, getFullDataBlog, formatType))
      rescue Exception => e
        raise e if index == @attempt
      end
      sleep 1.5
      index += 1
    end
  end

  def get_column_descriptions(aid)
    index = 1
    loop do
      begin
        return @pug_soap_service.getAssayColumnDescriptions(GetAssayColumnDescriptions.new(aid))
      rescue Exception => e
        raise e if index == @attempt
      end
      sleep 1.5
      index += 1
    end
  end
  def InputList(arr, type = PCIDType::EID_AID)
    index = 1
    loop do
      begin
        return @pug_soap_service.inputList(InputList.new(arr, type)).listKey
      rescue Exception => e
        raise e if index == @attempt
      end
      sleep 1.5
      index += 1
    end
  end

  def InputListText(ids, type = PCIDType::EID_CID)
    index = 1
    loop do
      begin
        return @pug_soap_service.inputListText(InputListText.new(ids, type)).listKey
      rescue Exception => e
        raise e if index == @attempt
      end
      sleep 1.5
      index += 1
    end

  end

  def Standardize(strKey)
    index = 1
    loop do
      begin
        stdResponse = @pug_soap_service.standardize(Standardize.new(strKey))
        return @pug_soap_service.wait_complete(stdResponse.strKey)
      rescue Exception => e
        raise e if index == @attempt
      end
      sleep 1.5
      index += 1
    end

  end

  def GetStandardizedCID(strKey)
    index = 1
    loop do
      begin
        @pug_soap_service.getStandardizedCID(GetStandardizedCID.new(strKey)).cID
      rescue Exception => e
        raise e if index == @attempt
      end
      sleep 1.5
      index += 1
    end
  end

  private
  def GetUrl(key)
    index = 1
    loop do
      begin
        return @pug_soap_service.getDownloadUrl(GetDownloadUrl.new(key)).url
      rescue Exception => e
        raise e if index == @attempt
      end
      sleep 1.5
      index += 1
    end


  end

  def query_term(term)
   term.gsub(/\s+/, '+').gsub('#', '%23').gsub('and', 'AND').gsub('or', 'OR').gsub('not', 'NOT')
  end

  def download_status(key)
    server_status = @pug_soap_service.wait_complete(key)
    return [server_status == key, server_status]
  end

end
