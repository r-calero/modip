require 'xsd/qname'

# {http://www.ncbi.nlm.nih.gov/soap/eutils/egquery}ResultItemType
#   dbName - SOAP::SOAPString
#   menuName - SOAP::SOAPString
#   count - SOAP::SOAPString
#   status - SOAP::SOAPString
class ResultItemType
  attr_accessor :dbName
  attr_accessor :menuName
  attr_accessor :count
  attr_accessor :status

  def initialize(dbName = nil, menuName = nil, count = nil, status = nil)
    @dbName = dbName
    @menuName = menuName
    @count = count
    @status = status
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/egquery}eGQueryResultType
#   eRROR - SOAP::SOAPString
#   resultItem - ResultItemType
class EGQueryResultType
  attr_accessor :eRROR
  attr_accessor :resultItem

  def initialize(eRROR = nil, resultItem = [])
    @eRROR = eRROR
    @resultItem = resultItem
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/einfo}DbInfoType
#   dbName - SOAP::SOAPString
#   menuName - SOAP::SOAPString
#   description - SOAP::SOAPString
#   count - SOAP::SOAPString
#   lastUpdate - SOAP::SOAPString
#   fieldList - FieldListType
#   linkList - LinkListType
class DbInfoType
  attr_accessor :dbName
  attr_accessor :menuName
  attr_accessor :description
  attr_accessor :count
  attr_accessor :lastUpdate
  attr_accessor :fieldList
  attr_accessor :linkList

  def initialize(dbName = nil, menuName = nil, description = nil, count = nil, lastUpdate = nil, fieldList = nil, linkList = nil)
    @dbName = dbName
    @menuName = menuName
    @description = description
    @count = count
    @lastUpdate = lastUpdate
    @fieldList = fieldList
    @linkList = linkList
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/einfo}DbListType
class DbListType < ::Array
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/einfo}FieldType
#   name - SOAP::SOAPString
#   fullName - SOAP::SOAPString
#   description - SOAP::SOAPString
#   termCount - SOAP::SOAPString
#   isDate - SOAP::SOAPString
#   isNumerical - SOAP::SOAPString
#   singleToken - SOAP::SOAPString
#   hierarchy - SOAP::SOAPString
#   isHidden - SOAP::SOAPString
class FieldType
  attr_accessor :name
  attr_accessor :fullName
  attr_accessor :description
  attr_accessor :termCount
  attr_accessor :isDate
  attr_accessor :isNumerical
  attr_accessor :singleToken
  attr_accessor :hierarchy
  attr_accessor :isHidden

  def initialize(name = nil, fullName = nil, description = nil, termCount = nil, isDate = nil, isNumerical = nil, singleToken = nil, hierarchy = nil, isHidden = nil)
    @name = name
    @fullName = fullName
    @description = description
    @termCount = termCount
    @isDate = isDate
    @isNumerical = isNumerical
    @singleToken = singleToken
    @hierarchy = hierarchy
    @isHidden = isHidden
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/einfo}FieldListType
class FieldListType < ::Array
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/einfo}LinkType
#   name - SOAP::SOAPString
#   menu - SOAP::SOAPString
#   description - SOAP::SOAPString
#   dbTo - SOAP::SOAPString
class LinkType
  attr_accessor :name
  attr_accessor :menu
  attr_accessor :description
  attr_accessor :dbTo

  def initialize(name = nil, menu = nil, description = nil, dbTo = nil)
    @name = name
    @menu = menu
    @description = description
    @dbTo = dbTo
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/einfo}LinkListType
class LinkListType < ::Array
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esearch}ErrorListType
#   phraseNotFound - SOAP::SOAPString
#   fieldNotFound - SOAP::SOAPString
class ErrorListType
  attr_accessor :phraseNotFound
  attr_accessor :fieldNotFound

  def initialize(phraseNotFound = [], fieldNotFound = [])
    @phraseNotFound = phraseNotFound
    @fieldNotFound = fieldNotFound
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esearch}IdListType
class IdListType < ::Array
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esearch}TermSetType
#   term - SOAP::SOAPString
#   field - SOAP::SOAPString
#   count - SOAP::SOAPString
#   explode - SOAP::SOAPString
class TermSetType
  attr_accessor :term
  attr_accessor :field
  attr_accessor :count
  attr_accessor :explode

  def initialize(term = nil, field = nil, count = nil, explode = nil)
    @term = term
    @field = field
    @count = count
    @explode = explode
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esearch}TranslationType
#   from - SOAP::SOAPString
#   to - SOAP::SOAPString
class TranslationType
  attr_accessor :from
  attr_accessor :to

  def initialize(from = nil, to = nil)
    @from = from
    @to = to
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esearch}TranslationSetType
class TranslationSetType < ::Array
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esearch}TranslationStackType
#   termSet - TermSetType
#   oP - SOAP::SOAPString
class TranslationStackType
  attr_accessor :termSet
  attr_accessor :oP

  def initialize(termSet = [], oP = [])
    @termSet = termSet
    @oP = oP
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esearch}WarningListType
#   phraseIgnored - SOAP::SOAPString
#   quotedPhraseNotFound - SOAP::SOAPString
#   outputMessage - SOAP::SOAPString
class WarningListType
  attr_accessor :phraseIgnored
  attr_accessor :quotedPhraseNotFound
  attr_accessor :outputMessage

  def initialize(phraseIgnored = [], quotedPhraseNotFound = [], outputMessage = [])
    @phraseIgnored = phraseIgnored
    @quotedPhraseNotFound = quotedPhraseNotFound
    @outputMessage = outputMessage
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esummary}DocSumType
#   id - SOAP::SOAPString
#   item - ItemType
class DocSumType
  attr_accessor :id
  attr_accessor :item

  def initialize(id = nil, item = [])
    @id = id
    @item = item
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esummary}ItemType
#   item - ItemType
#   itemContent - SOAP::SOAPString
#   xmlattr_Name - SOAP::SOAPString
#   xmlattr_Type - SOAP::SOAPNMTOKEN
class ItemType
  AttrName = XSD::QName.new(nil, "Name")
  AttrType = XSD::QName.new(nil, "Type")

  attr_accessor :item
  attr_accessor :itemContent

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_Name
    __xmlattr[AttrName]
  end

  def xmlattr_Name=(value)
    __xmlattr[AttrName] = value
  end

  def xmlattr_Type
    __xmlattr[AttrType]
  end

  def xmlattr_Type=(value)
    __xmlattr[AttrType] = value
  end

  def initialize(item = [], itemContent = nil)
    @item = item
    @itemContent = itemContent
    @__xmlattr = {}
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}FirstCharsType
class FirstCharsType < ::Array
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}IconUrlType
#   xmlattr_LNG - SOAP::SOAPNMTOKEN
class IconUrlType < ::String
  AttrLNG = XSD::QName.new(nil, "LNG")

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_LNG
    __xmlattr[AttrLNG]
  end

  def xmlattr_LNG=(value)
    __xmlattr[AttrLNG] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}IdType
#   xmlattr_HasLinkOut - SOAP::SOAPNMTOKEN
#   xmlattr_HasNeighbor - SOAP::SOAPNMTOKEN
class IdType < ::String
  AttrHasLinkOut = XSD::QName.new(nil, "HasLinkOut")
  AttrHasNeighbor = XSD::QName.new(nil, "HasNeighbor")

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_HasLinkOut
    __xmlattr[AttrHasLinkOut]
  end

  def xmlattr_HasLinkOut=(value)
    __xmlattr[AttrHasLinkOut] = value
  end

  def xmlattr_HasNeighbor
    __xmlattr[AttrHasNeighbor]
  end

  def xmlattr_HasNeighbor=(value)
    __xmlattr[AttrHasNeighbor] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}IdCheckListType
#   id - IdType
#   idLinkSet - IdLinkSetType
#   eRROR - SOAP::SOAPString
class IdCheckListType
  attr_accessor :id
  attr_accessor :idLinkSet
  attr_accessor :eRROR

  def initialize(id = [], idLinkSet = [], eRROR = nil)
    @id = id
    @idLinkSet = idLinkSet
    @eRROR = eRROR
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}IdLinkSetType
#   id - IdType
#   linkInfo - LinkInfoType
class IdLinkSetType
  attr_accessor :id
  attr_accessor :linkInfo

  def initialize(id = nil, linkInfo = [])
    @id = id
    @linkInfo = linkInfo
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}IdListType
class IdListType_ < ::Array
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}IdUrlListType
#   idUrlSet - IdUrlSetType
#   firstChars - FirstCharsType
class IdUrlListType
  attr_accessor :idUrlSet
  attr_accessor :firstChars

  def initialize(idUrlSet = [], firstChars = [])
    @idUrlSet = idUrlSet
    @firstChars = firstChars
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}IdUrlSetType
#   id - IdType
#   objUrl - ObjUrlType
#   info - SOAP::SOAPString
class IdUrlSetType
  attr_accessor :id
  attr_accessor :objUrl
  attr_accessor :info

  def initialize(id = nil, objUrl = [], info = nil)
    @id = id
    @objUrl = objUrl
    @info = info
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}LinkType
#   id - IdType
#   score - SOAP::SOAPString
class LinkType_
  attr_accessor :id
  attr_accessor :score

  def initialize(id = nil, score = nil)
    @id = id
    @score = score
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}LinkInfoType
#   dbTo - SOAP::SOAPString
#   linkName - SOAP::SOAPString
#   menuTag - SOAP::SOAPString
#   htmlTag - SOAP::SOAPString
#   url - UrlType
#   priority - SOAP::SOAPString
class LinkInfoType
  attr_accessor :dbTo
  attr_accessor :linkName
  attr_accessor :menuTag
  attr_accessor :htmlTag
  attr_accessor :url
  attr_accessor :priority

  def initialize(dbTo = nil, linkName = nil, menuTag = nil, htmlTag = nil, url = nil, priority = nil)
    @dbTo = dbTo
    @linkName = linkName
    @menuTag = menuTag
    @htmlTag = htmlTag
    @url = url
    @priority = priority
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}LinkSetType
#   dbFrom - SOAP::SOAPString
#   idList - IdListType_
#   linkSetDb - LinkSetDbType
#   linkSetDbHistory - LinkSetDbHistoryType
#   webEnv - SOAP::SOAPString
#   idUrlList - IdUrlListType
#   idCheckList - IdCheckListType
#   eRROR - SOAP::SOAPString
class LinkSetType
  attr_accessor :dbFrom
  attr_accessor :idList
  attr_accessor :linkSetDb
  attr_accessor :linkSetDbHistory
  attr_accessor :webEnv
  attr_accessor :idUrlList
  attr_accessor :idCheckList
  attr_accessor :eRROR

  def initialize(dbFrom = nil, idList = nil, linkSetDb = [], linkSetDbHistory = [], webEnv = nil, idUrlList = nil, idCheckList = nil, eRROR = nil)
    @dbFrom = dbFrom
    @idList = idList
    @linkSetDb = linkSetDb
    @linkSetDbHistory = linkSetDbHistory
    @webEnv = webEnv
    @idUrlList = idUrlList
    @idCheckList = idCheckList
    @eRROR = eRROR
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}LinkSetDbType
#   dbTo - SOAP::SOAPString
#   linkName - SOAP::SOAPString
#   link - LinkType_
#   info - SOAP::SOAPString
#   eRROR - SOAP::SOAPString
class LinkSetDbType
  attr_accessor :dbTo
  attr_accessor :linkName
  attr_accessor :link
  attr_accessor :info
  attr_accessor :eRROR

  def initialize(dbTo = nil, linkName = nil, link = [], info = nil, eRROR = nil)
    @dbTo = dbTo
    @linkName = linkName
    @link = link
    @info = info
    @eRROR = eRROR
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}LinkSetDbHistoryType
#   dbTo - SOAP::SOAPString
#   linkName - SOAP::SOAPString
#   queryKey - SOAP::SOAPString
#   info - SOAP::SOAPString
#   eRROR - SOAP::SOAPString
class LinkSetDbHistoryType
  attr_accessor :dbTo
  attr_accessor :linkName
  attr_accessor :queryKey
  attr_accessor :info
  attr_accessor :eRROR

  def initialize(dbTo = nil, linkName = nil, queryKey = nil, info = nil, eRROR = nil)
    @dbTo = dbTo
    @linkName = linkName
    @queryKey = queryKey
    @info = info
    @eRROR = eRROR
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}ObjUrlType
#   url - UrlType
#   iconUrl - IconUrlType
#   linkName - SOAP::SOAPString
#   subjectType - SOAP::SOAPString
#   category - SOAP::SOAPString
#   attribute - SOAP::SOAPString
#   provider - ProviderType
#   subProvider - SOAP::SOAPString
class ObjUrlType
  attr_accessor :url
  attr_accessor :iconUrl
  attr_accessor :linkName
  attr_accessor :subjectType
  attr_accessor :category
  attr_accessor :attribute
  attr_accessor :provider
  attr_accessor :subProvider

  def initialize(url = nil, iconUrl = nil, linkName = nil, subjectType = [], category = [], attribute = [], provider = nil, subProvider = nil)
    @url = url
    @iconUrl = iconUrl
    @linkName = linkName
    @subjectType = subjectType
    @category = category
    @attribute = attribute
    @provider = provider
    @subProvider = subProvider
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}ProviderType
#   name - SOAP::SOAPString
#   nameAbbr - SOAP::SOAPString
#   id - IdType
#   url - UrlType
#   iconUrl - IconUrlType
class ProviderType
  attr_accessor :name
  attr_accessor :nameAbbr
  attr_accessor :id
  attr_accessor :url
  attr_accessor :iconUrl

  def initialize(name = nil, nameAbbr = nil, id = nil, url = nil, iconUrl = nil)
    @name = name
    @nameAbbr = nameAbbr
    @id = id
    @url = url
    @iconUrl = iconUrl
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}UrlType
#   xmlattr_LNG - SOAP::SOAPNMTOKEN
class UrlType < ::String
  AttrLNG = XSD::QName.new(nil, "LNG")

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_LNG
    __xmlattr[AttrLNG]
  end

  def xmlattr_LNG=(value)
    __xmlattr[AttrLNG] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/epost}InvalidIdListType
class InvalidIdListType < ::Array
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/egquery}Result
#   term - SOAP::SOAPString
#   eGQueryResult - EGQueryResultType
class Result
  attr_accessor :term
  attr_accessor :eGQueryResult

  def initialize(term = nil, eGQueryResult = nil)
    @term = term
    @eGQueryResult = eGQueryResult
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/egquery}eGqueryRequest
#   term - SOAP::SOAPString
#   tool - SOAP::SOAPString
#   email - SOAP::SOAPString
class EGqueryRequest
  attr_accessor :term
  attr_accessor :tool
  attr_accessor :email

  def initialize(term = nil, tool = nil, email = nil)
    @term = term
    @tool = tool
    @email = email
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/einfo}eInfoRequest
#   db - SOAP::SOAPString
#   tool - SOAP::SOAPString
#   email - SOAP::SOAPString
class EInfoRequest
  attr_accessor :db
  attr_accessor :tool
  attr_accessor :email

  def initialize(db = nil, tool = nil, email = nil)
    @db = db
    @tool = tool
    @email = email
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/einfo}eInfoResult
#   eRROR - SOAP::SOAPString
#   dbList - DbListType
#   dbInfo - DbInfoType
class EInfoResult
  attr_accessor :eRROR
  attr_accessor :dbList
  attr_accessor :dbInfo

  def initialize(eRROR = nil, dbList = nil, dbInfo = nil)
    @eRROR = eRROR
    @dbList = dbList
    @dbInfo = dbInfo
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esearch}eSearchResult
#   eRROR - SOAP::SOAPString
#   count - SOAP::SOAPString
#   retMax - SOAP::SOAPString
#   retStart - SOAP::SOAPString
#   queryKey - SOAP::SOAPString
#   webEnv - SOAP::SOAPString
#   idList - IdListType
#   translationSet - TranslationSetType
#   translationStack - TranslationStackType
#   queryTranslation - SOAP::SOAPString
#   errorList - ErrorListType
#   warningList - WarningListType
class ESearchResult
  attr_accessor :eRROR
  attr_accessor :count
  attr_accessor :retMax
  attr_accessor :retStart
  attr_accessor :queryKey
  attr_accessor :webEnv
  attr_accessor :idList
  attr_accessor :translationSet
  attr_accessor :translationStack
  attr_accessor :queryTranslation
  attr_accessor :errorList
  attr_accessor :warningList

  def initialize(eRROR = nil, count = nil, retMax = nil, retStart = nil, queryKey = nil, webEnv = nil, idList = nil, translationSet = nil, translationStack = nil, queryTranslation = nil, errorList = nil, warningList = nil)
    @eRROR = eRROR
    @count = count
    @retMax = retMax
    @retStart = retStart
    @queryKey = queryKey
    @webEnv = webEnv
    @idList = idList
    @translationSet = translationSet
    @translationStack = translationStack
    @queryTranslation = queryTranslation
    @errorList = errorList
    @warningList = warningList
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esearch}eSearchRequest
#   db - SOAP::SOAPString
#   term - SOAP::SOAPString
#   webEnv - SOAP::SOAPString
#   queryKey - SOAP::SOAPString
#   usehistory - SOAP::SOAPString
#   tool - SOAP::SOAPString
#   email - SOAP::SOAPString
#   field - SOAP::SOAPString
#   reldate - SOAP::SOAPString
#   mindate - SOAP::SOAPString
#   maxdate - SOAP::SOAPString
#   datetype - SOAP::SOAPString
#   retStart - SOAP::SOAPString
#   retMax - SOAP::SOAPString
#   rettype - SOAP::SOAPString
#   sort - SOAP::SOAPString
class ESearchRequest
  attr_accessor :db
  attr_accessor :term
  attr_accessor :webEnv
  attr_accessor :queryKey
  attr_accessor :usehistory
  attr_accessor :tool
  attr_accessor :email
  attr_accessor :field
  attr_accessor :reldate
  attr_accessor :mindate
  attr_accessor :maxdate
  attr_accessor :datetype
  attr_accessor :retStart
  attr_accessor :retMax
  attr_accessor :rettype
  attr_accessor :sort

  def initialize(db = nil, term = nil, webEnv = nil, queryKey = nil, usehistory = nil, tool = nil, email = nil, field = nil, reldate = nil, mindate = nil, maxdate = nil, datetype = nil, retStart = nil, retMax = nil, rettype = nil, sort = nil)
    @db = db
    @term = term
    @webEnv = webEnv
    @queryKey = queryKey
    @usehistory = usehistory
    @tool = tool
    @email = email
    @field = field
    @reldate = reldate
    @mindate = mindate
    @maxdate = maxdate
    @datetype = datetype
    @retStart = retStart
    @retMax = retMax
    @rettype = rettype
    @sort = sort
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esummary}eSummaryResult
#   eRROR - SOAP::SOAPString
#   docSum - DocSumType
class ESummaryResult
  attr_accessor :eRROR
  attr_accessor :docSum

  def initialize(eRROR = nil, docSum = [])
    @eRROR = eRROR
    @docSum = docSum
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/esummary}eSummaryRequest
#   db - SOAP::SOAPString
#   id - SOAP::SOAPString
#   webEnv - SOAP::SOAPString
#   query_key - SOAP::SOAPString
#   retstart - SOAP::SOAPString
#   retmax - SOAP::SOAPString
#   tool - SOAP::SOAPString
#   email - SOAP::SOAPString
class ESummaryRequest
  attr_accessor :db
  attr_accessor :id
  attr_accessor :webEnv
  attr_accessor :query_key
  attr_accessor :retstart
  attr_accessor :retmax
  attr_accessor :tool
  attr_accessor :email

  def initialize(db = nil, id = nil, webEnv = nil, query_key = nil, retstart = nil, retmax = nil, tool = nil, email = nil)
    @db = db
    @id = id
    @webEnv = webEnv
    @query_key = query_key
    @retstart = retstart
    @retmax = retmax
    @tool = tool
    @email = email
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}eLinkResult
#   linkSet - LinkSetType
#   eRROR - SOAP::SOAPString
class ELinkResult
  attr_accessor :linkSet
  attr_accessor :eRROR

  def initialize(linkSet = [], eRROR = nil)
    @linkSet = linkSet
    @eRROR = eRROR
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/elink}eLinkRequest
#   db - SOAP::SOAPString
#   id - SOAP::SOAPString
#   reldate - SOAP::SOAPString
#   mindate - SOAP::SOAPString
#   maxdate - SOAP::SOAPString
#   datetype - SOAP::SOAPString
#   term - SOAP::SOAPString
#   dbfrom - SOAP::SOAPString
#   linkname - SOAP::SOAPString
#   webEnv - SOAP::SOAPString
#   query_key - SOAP::SOAPString
#   cmd - SOAP::SOAPString
#   tool - SOAP::SOAPString
#   email - SOAP::SOAPString
class ELinkRequest
  attr_accessor :db
  attr_accessor :id
  attr_accessor :reldate
  attr_accessor :mindate
  attr_accessor :maxdate
  attr_accessor :datetype
  attr_accessor :term
  attr_accessor :dbfrom
  attr_accessor :linkname
  attr_accessor :webEnv
  attr_accessor :query_key
  attr_accessor :cmd
  attr_accessor :tool
  attr_accessor :email

  def initialize(db = nil, id = [], reldate = nil, mindate = nil, maxdate = nil, datetype = nil, term = nil, dbfrom = nil, linkname = nil, webEnv = nil, query_key = nil, cmd = nil, tool = nil, email = nil)
    @db = db
    @id = id
    @reldate = reldate
    @mindate = mindate
    @maxdate = maxdate
    @datetype = datetype
    @term = term
    @dbfrom = dbfrom
    @linkname = linkname
    @webEnv = webEnv
    @query_key = query_key
    @cmd = cmd
    @tool = tool
    @email = email
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/espell}SpelledQuery
#   replaced - SOAP::SOAPString
#   original - SOAP::SOAPString
class SpelledQuery
  attr_accessor :replaced
  attr_accessor :original

  def initialize(replaced = [], original = [])
    @replaced = replaced
    @original = original
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/espell}eSpellResult
#   database - SOAP::SOAPString
#   query - SOAP::SOAPString
#   correctedQuery - SOAP::SOAPString
#   spelledQuery - SpelledQuery
#   eRROR - SOAP::SOAPString
class ESpellResult
  attr_accessor :database
  attr_accessor :query
  attr_accessor :correctedQuery
  attr_accessor :spelledQuery
  attr_accessor :eRROR

  def initialize(database = nil, query = nil, correctedQuery = nil, spelledQuery = nil, eRROR = nil)
    @database = database
    @query = query
    @correctedQuery = correctedQuery
    @spelledQuery = spelledQuery
    @eRROR = eRROR
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/espell}eSpellRequest
#   db - SOAP::SOAPString
#   term - SOAP::SOAPString
#   tool - SOAP::SOAPString
#   email - SOAP::SOAPString
class ESpellRequest
  attr_accessor :db
  attr_accessor :term
  attr_accessor :tool
  attr_accessor :email

  def initialize(db = nil, term = nil, tool = nil, email = nil)
    @db = db
    @term = term
    @tool = tool
    @email = email
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/epost}ePostResult
#   invalidIdList - InvalidIdListType
#   queryKey - SOAP::SOAPString
#   webEnv - SOAP::SOAPString
#   eRROR - SOAP::SOAPString
class EPostResult
  attr_accessor :invalidIdList
  attr_accessor :queryKey
  attr_accessor :webEnv
  attr_accessor :eRROR

  def initialize(invalidIdList = nil, queryKey = nil, webEnv = nil, eRROR = nil)
    @invalidIdList = invalidIdList
    @queryKey = queryKey
    @webEnv = webEnv
    @eRROR = eRROR
  end
end

# {http://www.ncbi.nlm.nih.gov/soap/eutils/epost}ePostRequest
#   db - SOAP::SOAPString
#   id - SOAP::SOAPString
#   webEnv - SOAP::SOAPString
#   tool - SOAP::SOAPString
#   email - SOAP::SOAPString
class EPostRequest
  attr_accessor :db
  attr_accessor :id
  attr_accessor :webEnv
  attr_accessor :tool
  attr_accessor :email

  def initialize(db = nil, id = nil, webEnv = nil, tool = nil, email = nil)
    @db = db
    @id = id
    @webEnv = webEnv
    @tool = tool
    @email = email
  end
end
