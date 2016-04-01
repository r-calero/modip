require 'cgi'
require 'pubchem/eUtils Service/defaultDriver'
require 'pubchem/service/defaultDriver'


class ServiceSoap
  
  attr_reader :proxy

  def initialize(proxy = nil, attempt = 10)
    @proxy = proxy
    @attempt = attempt
    #inicializa el servicio SOAP
    @pug_soap_service = PUGSoap.new()
    @eutils_service = EUtilsServiceSoap.new()
    @pug_soap_service.httpproxy = @proxy
    @eutils_service.httpproxy = @proxy

  end

  def proxy
    return @proxy

  end

  def proxy= (other)
    @proxy = other
    @pug_soap_service.httpproxy = @proxy
    @eutils_service.httpproxy = @proxy

  end

  def eSearch(db, term, opt)
     query = query_term(term)
     index = 1
     loop do
       eSearchResult = @eutils_service.run_eSearch(ESearchRequest.new(db, query, opt[:webEnv], opt[:queryKey], opt[:useHistory], opt[:tool], opt[:email], opt[:field], opt[:reldate], opt[:mindate], opt[:maxdate], opt[:datetype], opt[:retStart], opt[:retMax], opt[:rettype], opt[:sort]))
       if eSearchResult.eRROR != nil
        raise RuntimeError.new(eSearchResult.eRROR) if index == @attempt
       elsif eSearchResult.warningList != nil
        raise RuntimeError.new(eSearchResult.warningList.outputMessage) if index == @attempt
       else
        return eSearchResult
       end
       sleep 1.5
       index += 1
     end
  end

  def GetAssayUrl(aid, assayColumnType, assayFormat, compressType, assayOutcomeFilterType = nil, listKeyTIDs = nil, listKeySCIDs = nil)
    index = 1
    loop do
      begin
        assayKey =  @pug_soap_service.inputAssay(InputAssay.new(aid, assayColumnType, listKeyTIDs, listKeySCIDs, assayOutcomeFilterType))
        dwlKey = @pug_soap_service.assayDownload(AssayDownload.new(assayKey.assayKey, assayFormat, compressType))
        return GetUrl(dwlKey)
      rescue Exception => e
        raise e if index == @attempt
      end
      sleep 1.5
      index += 1
    end

  end

  def GetSCIDUrl(listKey, compInfo, use3D = true)
    index = 1
    loop do
      begin
        dwlKey = @pug_soap_service.download(Download.new(listKey, compInfo[:format], compInfo[:compress], use3D))
        return GetUrl(dwlKey)
      rescue Exception => e
        raise e if index == @attempt
      end
      sleep 1.5
      index += 1
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
  def GetUrl(dwlKey)
    index = 1
    loop do
      begin
        urlKey = @pug_soap_service.wait_complete(dwlKey.downloadKey)
        return @pug_soap_service.getDownloadUrl(GetDownloadUrl.new(urlKey)).url
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

end





