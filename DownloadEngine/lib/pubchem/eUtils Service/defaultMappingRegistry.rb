require 'rubygems'
gem 'soap4r'
require 'pubchem/eUtils Service/default'
require 'soap/mapping'

module DefaultMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsEgquery = "http://www.ncbi.nlm.nih.gov/soap/eutils/egquery"
  NsEinfo = "http://www.ncbi.nlm.nih.gov/soap/eutils/einfo"
  NsElink = "http://www.ncbi.nlm.nih.gov/soap/eutils/elink"
  NsEpost = "http://www.ncbi.nlm.nih.gov/soap/eutils/epost"
  NsEsearch = "http://www.ncbi.nlm.nih.gov/soap/eutils/esearch"
  NsEspell = "http://www.ncbi.nlm.nih.gov/soap/eutils/espell"
  NsEsummary = "http://www.ncbi.nlm.nih.gov/soap/eutils/esummary"

  EncodedRegistry.register(
    :class => ResultItemType,
    :schema_type => XSD::QName.new(NsEgquery, "ResultItemType"),
    :schema_element => [
      ["dbName", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "DbName")]],
      ["menuName", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "MenuName")]],
      ["count", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "Count")]],
      ["status", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "Status")]]
    ]
  )

  EncodedRegistry.register(
    :class => EGQueryResultType,
    :schema_type => XSD::QName.new(NsEgquery, "eGQueryResultType"),
    :schema_element => [
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "ERROR")], [0, 1]],
      ["resultItem", ["ResultItemType[]", XSD::QName.new(NsEgquery, "ResultItem")], [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => DbInfoType,
    :schema_type => XSD::QName.new(NsEinfo, "DbInfoType"),
    :schema_element => [
      ["dbName", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "DbName")]],
      ["menuName", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "MenuName")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Description")]],
      ["count", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Count")]],
      ["lastUpdate", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "LastUpdate")]],
      ["fieldList", ["FieldListType", XSD::QName.new(NsEinfo, "FieldList")]],
      ["linkList", ["LinkListType", XSD::QName.new(NsEinfo, "LinkList")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => DbListType,
    :schema_type => XSD::QName.new(NsEinfo, "DbListType"),
    :schema_element => [
      ["dbName", ["SOAP::SOAPString[]", XSD::QName.new(NsEinfo, "DbName")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => FieldType,
    :schema_type => XSD::QName.new(NsEinfo, "FieldType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Name")]],
      ["fullName", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "FullName")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Description")]],
      ["termCount", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "TermCount")]],
      ["isDate", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "IsDate")]],
      ["isNumerical", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "IsNumerical")]],
      ["singleToken", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "SingleToken")]],
      ["hierarchy", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Hierarchy")]],
      ["isHidden", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "IsHidden")]]
    ]
  )

  EncodedRegistry.register(
    :class => FieldListType,
    :schema_type => XSD::QName.new(NsEinfo, "FieldListType"),
    :schema_element => [
      ["field", ["FieldType[]", XSD::QName.new(NsEinfo, "Field")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => LinkType,
    :schema_type => XSD::QName.new(NsEinfo, "LinkType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Name")]],
      ["menu", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Menu")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Description")]],
      ["dbTo", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "DbTo")]]
    ]
  )

  EncodedRegistry.register(
    :class => LinkListType,
    :schema_type => XSD::QName.new(NsEinfo, "LinkListType"),
    :schema_element => [
      ["link", ["LinkType[]", XSD::QName.new(NsEinfo, "Link")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => ErrorListType,
    :schema_type => XSD::QName.new(NsEsearch, "ErrorListType"),
    :schema_element => [
      ["phraseNotFound", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "PhraseNotFound")], [0, nil]],
      ["fieldNotFound", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "FieldNotFound")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => IdListType,
    :schema_type => XSD::QName.new(NsEsearch, "IdListType"),
    :schema_element => [
      ["id", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "Id")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => TermSetType,
    :schema_type => XSD::QName.new(NsEsearch, "TermSetType"),
    :schema_element => [
      ["term", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "Term")]],
      ["field", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "Field")]],
      ["count", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "Count")]],
      ["explode", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "Explode")]]
    ]
  )

  EncodedRegistry.register(
    :class => TranslationType,
    :schema_type => XSD::QName.new(NsEsearch, "TranslationType"),
    :schema_element => [
      ["from", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "From")]],
      ["to", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "To")]]
    ]
  )

  EncodedRegistry.register(
    :class => TranslationSetType,
    :schema_type => XSD::QName.new(NsEsearch, "TranslationSetType"),
    :schema_element => [
      ["translation", ["TranslationType[]", XSD::QName.new(NsEsearch, "Translation")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => TranslationStackType,
    :schema_type => XSD::QName.new(NsEsearch, "TranslationStackType"),
    :schema_element => [ :choice,
      ["termSet", ["TermSetType[]", XSD::QName.new(NsEsearch, "TermSet")]],
      ["oP", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "OP")]]
    ]
  )

  EncodedRegistry.register(
    :class => WarningListType,
    :schema_type => XSD::QName.new(NsEsearch, "WarningListType"),
    :schema_element => [
      ["phraseIgnored", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "PhraseIgnored")], [0, nil]],
      ["quotedPhraseNotFound", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "QuotedPhraseNotFound")], [0, nil]],
      ["outputMessage", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "OutputMessage")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => DocSumType,
    :schema_type => XSD::QName.new(NsEsummary, "DocSumType"),
    :schema_element => [
      ["id", ["SOAP::SOAPString", XSD::QName.new(NsEsummary, "Id")]],
      ["item", ["ItemType[]", XSD::QName.new(NsEsummary, "Item")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => ItemType,
    :schema_type => XSD::QName.new(NsEsummary, "ItemType"),
    :schema_element => [
      ["item", ["ItemType[]", XSD::QName.new(NsEsummary, "Item")], [0, nil]],
      ["itemContent", ["SOAP::SOAPString", XSD::QName.new(NsEsummary, "ItemContent")], [0, 1]]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "Name") => "SOAP::SOAPString",
      XSD::QName.new(nil, "Type") => "SOAP::SOAPNMTOKEN"
    }
  )

  EncodedRegistry.register(
    :class => FirstCharsType,
    :schema_type => XSD::QName.new(NsElink, "FirstCharsType"),
    :schema_element => [
      ["firstChar", ["SOAP::SOAPString[]", XSD::QName.new(NsElink, "FirstChar")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => IconUrlType,
    :schema_type => XSD::QName.new(NsElink, "IconUrlType"),
    :schema_attribute => {
      XSD::QName.new(nil, "LNG") => "SOAP::SOAPNMTOKEN"
    }
  )

  EncodedRegistry.register(
    :class => IdType,
    :schema_type => XSD::QName.new(NsElink, "IdType"),
    :schema_attribute => {
      XSD::QName.new(nil, "HasLinkOut") => "SOAP::SOAPNMTOKEN",
      XSD::QName.new(nil, "HasNeighbor") => "SOAP::SOAPNMTOKEN"
    }
  )

  EncodedRegistry.register(
    :class => IdCheckListType,
    :schema_type => XSD::QName.new(NsElink, "IdCheckListType"),
    :schema_element => [
      [
        ["id", ["IdType[]", XSD::QName.new(NsElink, "Id")]],
        ["idLinkSet", ["IdLinkSetType[]", XSD::QName.new(NsElink, "IdLinkSet")]]
      ],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsElink, "ERROR")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => IdLinkSetType,
    :schema_type => XSD::QName.new(NsElink, "IdLinkSetType"),
    :schema_element => [
      ["id", ["IdType", XSD::QName.new(NsElink, "Id")]],
      ["linkInfo", ["LinkInfoType[]", XSD::QName.new(NsElink, "LinkInfo")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => IdListType_,
    :schema_type => XSD::QName.new(NsElink, "IdListType"),
    :schema_element => [
      ["id", ["IdType[]", XSD::QName.new(NsElink, "Id")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => IdUrlListType,
    :schema_type => XSD::QName.new(NsElink, "IdUrlListType"),
    :schema_element => [ :choice,
      ["idUrlSet", ["IdUrlSetType[]", XSD::QName.new(NsElink, "IdUrlSet")], [0, nil]],
      ["firstChars", ["FirstCharsType[]", XSD::QName.new(NsElink, "FirstChars")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => IdUrlSetType,
    :schema_type => XSD::QName.new(NsElink, "IdUrlSetType"),
    :schema_element => [
      ["id", ["IdType", XSD::QName.new(NsElink, "Id")]],
      [ :choice,
        ["objUrl", ["ObjUrlType[]", XSD::QName.new(NsElink, "ObjUrl")], [1, nil]],
        ["info", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Info")]]
      ]
    ]
  )

  EncodedRegistry.register(
    :class => LinkType_,
    :schema_type => XSD::QName.new(NsElink, "LinkType"),
    :schema_element => [
      ["id", ["IdType", XSD::QName.new(NsElink, "Id")]],
      ["score", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Score")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LinkInfoType,
    :schema_type => XSD::QName.new(NsElink, "LinkInfoType"),
    :schema_element => [
      ["dbTo", ["SOAP::SOAPString", XSD::QName.new(NsElink, "DbTo")]],
      ["linkName", ["SOAP::SOAPString", XSD::QName.new(NsElink, "LinkName")]],
      ["menuTag", ["SOAP::SOAPString", XSD::QName.new(NsElink, "MenuTag")], [0, 1]],
      ["htmlTag", ["SOAP::SOAPString", XSD::QName.new(NsElink, "HtmlTag")], [0, 1]],
      ["url", ["UrlType", XSD::QName.new(NsElink, "Url")], [0, 1]],
      ["priority", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Priority")]]
    ]
  )

  EncodedRegistry.register(
    :class => LinkSetType,
    :schema_type => XSD::QName.new(NsElink, "LinkSetType"),
    :schema_element => [
      ["dbFrom", ["SOAP::SOAPString", XSD::QName.new(NsElink, "DbFrom")]],
      ["idList", ["IdListType_", XSD::QName.new(NsElink, "IdList")], [0, 1]],
      ["linkSetDb", ["LinkSetDbType[]", XSD::QName.new(NsElink, "LinkSetDb")], [0, nil]],
      ["linkSetDbHistory", ["LinkSetDbHistoryType[]", XSD::QName.new(NsElink, "LinkSetDbHistory")], [0, nil]],
      ["webEnv", ["SOAP::SOAPString", XSD::QName.new(NsElink, "WebEnv")], [0, 1]],
      ["idUrlList", ["IdUrlListType", XSD::QName.new(NsElink, "IdUrlList")], [0, 1]],
      ["idCheckList", ["IdCheckListType", XSD::QName.new(NsElink, "IdCheckList")], [0, 1]],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsElink, "ERROR")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LinkSetDbType,
    :schema_type => XSD::QName.new(NsElink, "LinkSetDbType"),
    :schema_element => [
      ["dbTo", ["SOAP::SOAPString", XSD::QName.new(NsElink, "DbTo")]],
      ["linkName", ["SOAP::SOAPString", XSD::QName.new(NsElink, "LinkName")]],
      ["link", ["LinkType_[]", XSD::QName.new(NsElink, "Link")], [0, nil]],
      ["info", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Info")], [0, 1]],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsElink, "ERROR")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LinkSetDbHistoryType,
    :schema_type => XSD::QName.new(NsElink, "LinkSetDbHistoryType"),
    :schema_element => [
      ["dbTo", ["SOAP::SOAPString", XSD::QName.new(NsElink, "DbTo")]],
      ["linkName", ["SOAP::SOAPString", XSD::QName.new(NsElink, "LinkName")]],
      ["queryKey", ["SOAP::SOAPString", XSD::QName.new(NsElink, "QueryKey")]],
      ["info", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Info")]],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsElink, "ERROR")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => ObjUrlType,
    :schema_type => XSD::QName.new(NsElink, "ObjUrlType"),
    :schema_element => [
      ["url", ["UrlType", XSD::QName.new(NsElink, "Url")]],
      ["iconUrl", ["IconUrlType", XSD::QName.new(NsElink, "IconUrl")], [0, 1]],
      ["linkName", ["SOAP::SOAPString", XSD::QName.new(NsElink, "LinkName")], [0, 1]],
      ["subjectType", ["SOAP::SOAPString[]", XSD::QName.new(NsElink, "SubjectType")], [0, nil]],
      ["category", ["SOAP::SOAPString[]", XSD::QName.new(NsElink, "Category")], [0, nil]],
      ["attribute", ["SOAP::SOAPString[]", XSD::QName.new(NsElink, "Attribute")], [0, nil]],
      ["provider", ["ProviderType", XSD::QName.new(NsElink, "Provider")]],
      ["subProvider", ["SOAP::SOAPString", XSD::QName.new(NsElink, "SubProvider")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => ProviderType,
    :schema_type => XSD::QName.new(NsElink, "ProviderType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Name")]],
      ["nameAbbr", ["SOAP::SOAPString", XSD::QName.new(NsElink, "NameAbbr")]],
      ["id", ["IdType", XSD::QName.new(NsElink, "Id")]],
      ["url", ["UrlType", XSD::QName.new(NsElink, "Url")]],
      ["iconUrl", ["IconUrlType", XSD::QName.new(NsElink, "IconUrl")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => UrlType,
    :schema_type => XSD::QName.new(NsElink, "UrlType"),
    :schema_attribute => {
      XSD::QName.new(nil, "LNG") => "SOAP::SOAPNMTOKEN"
    }
  )

  EncodedRegistry.register(
    :class => InvalidIdListType,
    :schema_type => XSD::QName.new(NsEpost, "InvalidIdListType"),
    :schema_element => [
      ["id", ["SOAP::SOAPString[]", XSD::QName.new(NsEpost, "Id")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => ResultItemType,
    :schema_type => XSD::QName.new(NsEgquery, "ResultItemType"),
    :schema_element => [
      ["dbName", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "DbName")]],
      ["menuName", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "MenuName")]],
      ["count", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "Count")]],
      ["status", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "Status")]]
    ]
  )

  LiteralRegistry.register(
    :class => EGQueryResultType,
    :schema_type => XSD::QName.new(NsEgquery, "eGQueryResultType"),
    :schema_element => [
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "ERROR")], [0, 1]],
      ["resultItem", ["ResultItemType[]", XSD::QName.new(NsEgquery, "ResultItem")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => DbInfoType,
    :schema_type => XSD::QName.new(NsEinfo, "DbInfoType"),
    :schema_element => [
      ["dbName", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "DbName")]],
      ["menuName", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "MenuName")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Description")]],
      ["count", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Count")]],
      ["lastUpdate", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "LastUpdate")]],
      ["fieldList", ["FieldListType", XSD::QName.new(NsEinfo, "FieldList")]],
      ["linkList", ["LinkListType", XSD::QName.new(NsEinfo, "LinkList")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => DbListType,
    :schema_type => XSD::QName.new(NsEinfo, "DbListType"),
    :schema_element => [
      ["dbName", ["SOAP::SOAPString[]", XSD::QName.new(NsEinfo, "DbName")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => FieldType,
    :schema_type => XSD::QName.new(NsEinfo, "FieldType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Name")]],
      ["fullName", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "FullName")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Description")]],
      ["termCount", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "TermCount")]],
      ["isDate", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "IsDate")]],
      ["isNumerical", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "IsNumerical")]],
      ["singleToken", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "SingleToken")]],
      ["hierarchy", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Hierarchy")]],
      ["isHidden", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "IsHidden")]]
    ]
  )

  LiteralRegistry.register(
    :class => FieldListType,
    :schema_type => XSD::QName.new(NsEinfo, "FieldListType"),
    :schema_element => [
      ["field", ["FieldType[]", XSD::QName.new(NsEinfo, "Field")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => LinkType,
    :schema_type => XSD::QName.new(NsEinfo, "LinkType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Name")]],
      ["menu", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Menu")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "Description")]],
      ["dbTo", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "DbTo")]]
    ]
  )

  LiteralRegistry.register(
    :class => LinkListType,
    :schema_type => XSD::QName.new(NsEinfo, "LinkListType"),
    :schema_element => [
      ["link", ["LinkType[]", XSD::QName.new(NsEinfo, "Link")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => ErrorListType,
    :schema_type => XSD::QName.new(NsEsearch, "ErrorListType"),
    :schema_element => [
      ["phraseNotFound", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "PhraseNotFound")], [0, nil]],
      ["fieldNotFound", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "FieldNotFound")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => IdListType,
    :schema_type => XSD::QName.new(NsEsearch, "IdListType"),
    :schema_element => [
      ["id", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "Id")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => TermSetType,
    :schema_type => XSD::QName.new(NsEsearch, "TermSetType"),
    :schema_element => [
      ["term", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "Term")]],
      ["field", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "Field")]],
      ["count", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "Count")]],
      ["explode", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "Explode")]]
    ]
  )

  LiteralRegistry.register(
    :class => TranslationType,
    :schema_type => XSD::QName.new(NsEsearch, "TranslationType"),
    :schema_element => [
      ["from", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "From")]],
      ["to", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "To")]]
    ]
  )

  LiteralRegistry.register(
    :class => TranslationSetType,
    :schema_type => XSD::QName.new(NsEsearch, "TranslationSetType"),
    :schema_element => [
      ["translation", ["TranslationType[]", XSD::QName.new(NsEsearch, "Translation")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => TranslationStackType,
    :schema_type => XSD::QName.new(NsEsearch, "TranslationStackType"),
    :schema_element => [ :choice,
      ["termSet", ["TermSetType[]", XSD::QName.new(NsEsearch, "TermSet")]],
      ["oP", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "OP")]]
    ]
  )

  LiteralRegistry.register(
    :class => WarningListType,
    :schema_type => XSD::QName.new(NsEsearch, "WarningListType"),
    :schema_element => [
      ["phraseIgnored", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "PhraseIgnored")], [0, nil]],
      ["quotedPhraseNotFound", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "QuotedPhraseNotFound")], [0, nil]],
      ["outputMessage", ["SOAP::SOAPString[]", XSD::QName.new(NsEsearch, "OutputMessage")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => DocSumType,
    :schema_type => XSD::QName.new(NsEsummary, "DocSumType"),
    :schema_element => [
      ["id", ["SOAP::SOAPString", XSD::QName.new(NsEsummary, "Id")]],
      ["item", ["ItemType[]", XSD::QName.new(NsEsummary, "Item")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => ItemType,
    :schema_type => XSD::QName.new(NsEsummary, "ItemType"),
    :schema_element => [
      ["item", ["ItemType[]", XSD::QName.new(NsEsummary, "Item")], [0, nil]],
      ["itemContent", ["SOAP::SOAPString", XSD::QName.new(NsEsummary, "ItemContent")], [0, 1]]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "Name") => "SOAP::SOAPString",
      XSD::QName.new(nil, "Type") => "SOAP::SOAPNMTOKEN"
    }
  )

  LiteralRegistry.register(
    :class => FirstCharsType,
    :schema_type => XSD::QName.new(NsElink, "FirstCharsType"),
    :schema_element => [
      ["firstChar", ["SOAP::SOAPString[]", XSD::QName.new(NsElink, "FirstChar")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => IconUrlType,
    :schema_type => XSD::QName.new(NsElink, "IconUrlType"),
    :schema_attribute => {
      XSD::QName.new(nil, "LNG") => "SOAP::SOAPNMTOKEN"
    }
  )

  LiteralRegistry.register(
    :class => IdType,
    :schema_type => XSD::QName.new(NsElink, "IdType"),
    :schema_attribute => {
      XSD::QName.new(nil, "HasLinkOut") => "SOAP::SOAPNMTOKEN",
      XSD::QName.new(nil, "HasNeighbor") => "SOAP::SOAPNMTOKEN"
    }
  )

  LiteralRegistry.register(
    :class => IdCheckListType,
    :schema_type => XSD::QName.new(NsElink, "IdCheckListType"),
    :schema_element => [
      [
        ["id", ["IdType[]", XSD::QName.new(NsElink, "Id")]],
        ["idLinkSet", ["IdLinkSetType[]", XSD::QName.new(NsElink, "IdLinkSet")]]
      ],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsElink, "ERROR")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => IdLinkSetType,
    :schema_type => XSD::QName.new(NsElink, "IdLinkSetType"),
    :schema_element => [
      ["id", ["IdType", XSD::QName.new(NsElink, "Id")]],
      ["linkInfo", ["LinkInfoType[]", XSD::QName.new(NsElink, "LinkInfo")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => IdListType_,
    :schema_type => XSD::QName.new(NsElink, "IdListType"),
    :schema_element => [
      ["id", ["IdType[]", XSD::QName.new(NsElink, "Id")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => IdUrlListType,
    :schema_type => XSD::QName.new(NsElink, "IdUrlListType"),
    :schema_element => [ :choice,
      ["idUrlSet", ["IdUrlSetType[]", XSD::QName.new(NsElink, "IdUrlSet")], [0, nil]],
      ["firstChars", ["FirstCharsType[]", XSD::QName.new(NsElink, "FirstChars")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => IdUrlSetType,
    :schema_type => XSD::QName.new(NsElink, "IdUrlSetType"),
    :schema_element => [
      ["id", ["IdType", XSD::QName.new(NsElink, "Id")]],
      [ :choice,
        ["objUrl", ["ObjUrlType[]", XSD::QName.new(NsElink, "ObjUrl")], [1, nil]],
        ["info", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Info")]]
      ]
    ]
  )

  LiteralRegistry.register(
    :class => LinkType_,
    :schema_type => XSD::QName.new(NsElink, "LinkType"),
    :schema_element => [
      ["id", ["IdType", XSD::QName.new(NsElink, "Id")]],
      ["score", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Score")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LinkInfoType,
    :schema_type => XSD::QName.new(NsElink, "LinkInfoType"),
    :schema_element => [
      ["dbTo", ["SOAP::SOAPString", XSD::QName.new(NsElink, "DbTo")]],
      ["linkName", ["SOAP::SOAPString", XSD::QName.new(NsElink, "LinkName")]],
      ["menuTag", ["SOAP::SOAPString", XSD::QName.new(NsElink, "MenuTag")], [0, 1]],
      ["htmlTag", ["SOAP::SOAPString", XSD::QName.new(NsElink, "HtmlTag")], [0, 1]],
      ["url", ["UrlType", XSD::QName.new(NsElink, "Url")], [0, 1]],
      ["priority", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Priority")]]
    ]
  )

  LiteralRegistry.register(
    :class => LinkSetType,
    :schema_type => XSD::QName.new(NsElink, "LinkSetType"),
    :schema_element => [
      ["dbFrom", ["SOAP::SOAPString", XSD::QName.new(NsElink, "DbFrom")]],
      ["idList", ["IdListType_", XSD::QName.new(NsElink, "IdList")], [0, 1]],
      ["linkSetDb", ["LinkSetDbType[]", XSD::QName.new(NsElink, "LinkSetDb")], [0, nil]],
      ["linkSetDbHistory", ["LinkSetDbHistoryType[]", XSD::QName.new(NsElink, "LinkSetDbHistory")], [0, nil]],
      ["webEnv", ["SOAP::SOAPString", XSD::QName.new(NsElink, "WebEnv")], [0, 1]],
      ["idUrlList", ["IdUrlListType", XSD::QName.new(NsElink, "IdUrlList")], [0, 1]],
      ["idCheckList", ["IdCheckListType", XSD::QName.new(NsElink, "IdCheckList")], [0, 1]],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsElink, "ERROR")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LinkSetDbType,
    :schema_type => XSD::QName.new(NsElink, "LinkSetDbType"),
    :schema_element => [
      ["dbTo", ["SOAP::SOAPString", XSD::QName.new(NsElink, "DbTo")]],
      ["linkName", ["SOAP::SOAPString", XSD::QName.new(NsElink, "LinkName")]],
      ["link", ["LinkType_[]", XSD::QName.new(NsElink, "Link")], [0, nil]],
      ["info", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Info")], [0, 1]],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsElink, "ERROR")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LinkSetDbHistoryType,
    :schema_type => XSD::QName.new(NsElink, "LinkSetDbHistoryType"),
    :schema_element => [
      ["dbTo", ["SOAP::SOAPString", XSD::QName.new(NsElink, "DbTo")]],
      ["linkName", ["SOAP::SOAPString", XSD::QName.new(NsElink, "LinkName")]],
      ["queryKey", ["SOAP::SOAPString", XSD::QName.new(NsElink, "QueryKey")]],
      ["info", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Info")]],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsElink, "ERROR")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ObjUrlType,
    :schema_type => XSD::QName.new(NsElink, "ObjUrlType"),
    :schema_element => [
      ["url", ["UrlType", XSD::QName.new(NsElink, "Url")]],
      ["iconUrl", ["IconUrlType", XSD::QName.new(NsElink, "IconUrl")], [0, 1]],
      ["linkName", ["SOAP::SOAPString", XSD::QName.new(NsElink, "LinkName")], [0, 1]],
      ["subjectType", ["SOAP::SOAPString[]", XSD::QName.new(NsElink, "SubjectType")], [0, nil]],
      ["category", ["SOAP::SOAPString[]", XSD::QName.new(NsElink, "Category")], [0, nil]],
      ["attribute", ["SOAP::SOAPString[]", XSD::QName.new(NsElink, "Attribute")], [0, nil]],
      ["provider", ["ProviderType", XSD::QName.new(NsElink, "Provider")]],
      ["subProvider", ["SOAP::SOAPString", XSD::QName.new(NsElink, "SubProvider")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ProviderType,
    :schema_type => XSD::QName.new(NsElink, "ProviderType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsElink, "Name")]],
      ["nameAbbr", ["SOAP::SOAPString", XSD::QName.new(NsElink, "NameAbbr")]],
      ["id", ["IdType", XSD::QName.new(NsElink, "Id")]],
      ["url", ["UrlType", XSD::QName.new(NsElink, "Url")]],
      ["iconUrl", ["IconUrlType", XSD::QName.new(NsElink, "IconUrl")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => UrlType,
    :schema_type => XSD::QName.new(NsElink, "UrlType"),
    :schema_attribute => {
      XSD::QName.new(nil, "LNG") => "SOAP::SOAPNMTOKEN"
    }
  )

  LiteralRegistry.register(
    :class => InvalidIdListType,
    :schema_type => XSD::QName.new(NsEpost, "InvalidIdListType"),
    :schema_element => [
      ["id", ["SOAP::SOAPString[]", XSD::QName.new(NsEpost, "Id")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => Result,
    :schema_name => XSD::QName.new(NsEgquery, "Result"),
    :schema_element => [
      ["term", ["SOAP::SOAPString", XSD::QName.new(NsEgquery, "Term")]],
      ["eGQueryResult", "EGQueryResultType"]
    ]
  )

  LiteralRegistry.register(
    :class => EGqueryRequest,
    :schema_name => XSD::QName.new(NsEgquery, "eGqueryRequest"),
    :schema_element => [
      ["term", "SOAP::SOAPString", [0, 1]],
      ["tool", "SOAP::SOAPString", [0, 1]],
      ["email", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => EInfoRequest,
    :schema_name => XSD::QName.new(NsEinfo, "eInfoRequest"),
    :schema_element => [
      ["db", "SOAP::SOAPString", [0, 1]],
      ["tool", "SOAP::SOAPString", [0, 1]],
      ["email", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => EInfoResult,
    :schema_name => XSD::QName.new(NsEinfo, "eInfoResult"),
    :schema_element => [
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsEinfo, "ERROR")], [0, 1]],
      ["dbList", ["DbListType", XSD::QName.new(NsEinfo, "DbList")], [0, 1]],
      ["dbInfo", ["DbInfoType", XSD::QName.new(NsEinfo, "DbInfo")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ESearchResult,
    :schema_name => XSD::QName.new(NsEsearch, "eSearchResult"),
    :schema_element => [
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "ERROR")], [0, 1]],
      ["count", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "Count")], [0, 1]],
      ["retMax", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "RetMax")], [0, 1]],
      ["retStart", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "RetStart")], [0, 1]],
      ["queryKey", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "QueryKey")], [0, 1]],
      ["webEnv", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "WebEnv")], [0, 1]],
      ["idList", ["IdListType", XSD::QName.new(NsEsearch, "IdList")], [0, 1]],
      ["translationSet", ["TranslationSetType", XSD::QName.new(NsEsearch, "TranslationSet")], [0, 1]],
      ["translationStack", ["TranslationStackType", XSD::QName.new(NsEsearch, "TranslationStack")], [0, 1]],
      ["queryTranslation", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "QueryTranslation")], [0, 1]],
      ["errorList", ["ErrorListType", XSD::QName.new(NsEsearch, "ErrorList")], [0, 1]],
      ["warningList", ["WarningListType", XSD::QName.new(NsEsearch, "WarningList")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ESearchRequest,
    :schema_name => XSD::QName.new(NsEsearch, "eSearchRequest"),
    :schema_element => [
      ["db", "SOAP::SOAPString", [0, 1]],
      ["term", "SOAP::SOAPString", [0, 1]],
      ["webEnv", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "WebEnv")], [0, 1]],
      ["queryKey", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "QueryKey")], [0, 1]],
      ["usehistory", "SOAP::SOAPString", [0, 1]],
      ["tool", "SOAP::SOAPString", [0, 1]],
      ["email", "SOAP::SOAPString", [0, 1]],
      ["field", "SOAP::SOAPString", [0, 1]],
      ["reldate", "SOAP::SOAPString", [0, 1]],
      ["mindate", "SOAP::SOAPString", [0, 1]],
      ["maxdate", "SOAP::SOAPString", [0, 1]],
      ["datetype", "SOAP::SOAPString", [0, 1]],
      ["retStart", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "RetStart")], [0, 1]],
      ["retMax", ["SOAP::SOAPString", XSD::QName.new(NsEsearch, "RetMax")], [0, 1]],
      ["rettype", "SOAP::SOAPString", [0, 1]],
      ["sort", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ESummaryResult,
    :schema_name => XSD::QName.new(NsEsummary, "eSummaryResult"),
    :schema_element => [
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsEsummary, "ERROR")], [0, 1]],
      ["docSum", ["DocSumType[]", XSD::QName.new(NsEsummary, "DocSum")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => ESummaryRequest,
    :schema_name => XSD::QName.new(NsEsummary, "eSummaryRequest"),
    :schema_element => [
      ["db", "SOAP::SOAPString", [0, 1]],
      ["id", "SOAP::SOAPString", [0, 1]],
      ["webEnv", ["SOAP::SOAPString", XSD::QName.new(NsEsummary, "WebEnv")], [0, 1]],
      ["query_key", "SOAP::SOAPString", [0, 1]],
      ["retstart", "SOAP::SOAPString", [0, 1]],
      ["retmax", "SOAP::SOAPString", [0, 1]],
      ["tool", "SOAP::SOAPString", [0, 1]],
      ["email", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ELinkResult,
    :schema_name => XSD::QName.new(NsElink, "eLinkResult"),
    :schema_element => [
      ["linkSet", ["LinkSetType[]", XSD::QName.new(NsElink, "LinkSet")], [0, nil]],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsElink, "ERROR")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ELinkRequest,
    :schema_name => XSD::QName.new(NsElink, "eLinkRequest"),
    :schema_element => [
      ["db", "SOAP::SOAPString", [0, 1]],
      ["id", "SOAP::SOAPString[]", [0, nil]],
      ["reldate", "SOAP::SOAPString", [0, 1]],
      ["mindate", "SOAP::SOAPString", [0, 1]],
      ["maxdate", "SOAP::SOAPString", [0, 1]],
      ["datetype", "SOAP::SOAPString", [0, 1]],
      ["term", "SOAP::SOAPString", [0, 1]],
      ["dbfrom", "SOAP::SOAPString", [0, 1]],
      ["linkname", "SOAP::SOAPString", [0, 1]],
      ["webEnv", ["SOAP::SOAPString", XSD::QName.new(NsElink, "WebEnv")], [0, 1]],
      ["query_key", "SOAP::SOAPString", [0, 1]],
      ["cmd", "SOAP::SOAPString", [0, 1]],
      ["tool", "SOAP::SOAPString", [0, 1]],
      ["email", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => SpelledQuery,
    :schema_name => XSD::QName.new(NsEspell, "SpelledQuery"),
    :schema_element => [ :choice,
      ["replaced", ["SOAP::SOAPString[]", XSD::QName.new(NsEspell, "Replaced")]],
      ["original", ["SOAP::SOAPString[]", XSD::QName.new(NsEspell, "Original")]]
    ]
  )

  LiteralRegistry.register(
    :class => ESpellResult,
    :schema_name => XSD::QName.new(NsEspell, "eSpellResult"),
    :schema_element => [
      ["database", ["SOAP::SOAPString", XSD::QName.new(NsEspell, "Database")]],
      ["query", ["SOAP::SOAPString", XSD::QName.new(NsEspell, "Query")]],
      ["correctedQuery", ["SOAP::SOAPString", XSD::QName.new(NsEspell, "CorrectedQuery")]],
      ["spelledQuery", ["SpelledQuery", XSD::QName.new(NsEspell, "SpelledQuery")]],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsEspell, "ERROR")]]
    ]
  )

  LiteralRegistry.register(
    :class => ESpellRequest,
    :schema_name => XSD::QName.new(NsEspell, "eSpellRequest"),
    :schema_element => [
      ["db", "SOAP::SOAPString", [0, 1]],
      ["term", "SOAP::SOAPString", [0, 1]],
      ["tool", "SOAP::SOAPString", [0, 1]],
      ["email", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => EPostResult,
    :schema_name => XSD::QName.new(NsEpost, "ePostResult"),
    :schema_element => [
      ["invalidIdList", ["InvalidIdListType", XSD::QName.new(NsEpost, "InvalidIdList")], [0, 1]],
      ["queryKey", ["SOAP::SOAPString", XSD::QName.new(NsEpost, "QueryKey")], [0, 1]],
      ["webEnv", ["SOAP::SOAPString", XSD::QName.new(NsEpost, "WebEnv")], [0, 1]],
      ["eRROR", ["SOAP::SOAPString", XSD::QName.new(NsEpost, "ERROR")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => EPostRequest,
    :schema_name => XSD::QName.new(NsEpost, "ePostRequest"),
    :schema_element => [
      ["db", "SOAP::SOAPString", [0, 1]],
      ["id", "SOAP::SOAPString", [0, 1]],
      ["webEnv", ["SOAP::SOAPString", XSD::QName.new(NsEpost, "WebEnv")], [0, 1]],
      ["tool", "SOAP::SOAPString", [0, 1]],
      ["email", "SOAP::SOAPString", [0, 1]]
    ]
  )
end
