require 'pubchem/service/default'
require 'pubchem/service/defaultMappingRegistry'
require 'soap/rpc/driver'

class PUGSoap < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://pubchem.ncbi.nlm.nih.gov/pug_soap/pug_soap.cgi"

  Methods = [
    [ "http://pubchem.ncbi.nlm.nih.gov/AssayDownload",
      "assayDownload",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "AssayDownload"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "AssayDownloadResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/Download",
      "download",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "Download"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "DownloadResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetAssayColumnDescription",
      "getAssayColumnDescription",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetAssayColumnDescription"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetAssayColumnDescriptionResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetAssayColumnDescriptions",
      "getAssayColumnDescriptions",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetAssayColumnDescriptions"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetAssayColumnDescriptionsResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetAssayDescription",
      "getAssayDescription",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetAssayDescription"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetAssayDescriptionResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetDownloadUrl",
      "getDownloadUrl",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetDownloadUrl"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetDownloadUrlResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetEntrezKey",
      "getEntrezKey",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetEntrezKey"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetEntrezKeyResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetEntrezUrl",
      "getEntrezUrl",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetEntrezUrl"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetEntrezUrlResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetIDList",
      "getIDList",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetIDList"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetIDListResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetListItemsCount",
      "getListItemsCount",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetListItemsCount"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetListItemsCountResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetOperationStatus",
      "getOperationStatus",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetOperationStatus"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetOperationStatusResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetStandardizedCID",
      "getStandardizedCID",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetStandardizedCID"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetStandardizedCIDResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetStandardizedStructure",
      "getStandardizedStructure",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetStandardizedStructure"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetStandardizedStructureResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetStandardizedStructureBase64",
      "getStandardizedStructureBase64",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetStandardizedStructureBase64"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetStandardizedStructureBase64Response"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/GetStatusMessage",
      "getStatusMessage",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetStatusMessage"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "GetStatusMessageResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/IdentitySearch",
      "identitySearch",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "IdentitySearch"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "IdentitySearchResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/IDExchange",
      "iDExchange",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "IDExchange"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "IDExchangeResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/InputAssay",
      "inputAssay",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputAssay"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputAssayResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/InputEntrez",
      "inputEntrez",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputEntrez"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputEntrezResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/InputList",
      "inputList",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputList"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputListResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/InputListString",
      "inputListString",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputListString"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputListStringResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/InputListText",
      "inputListText",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputListText"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputListTextResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/InputStructure",
      "inputStructure",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputStructure"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputStructureResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/InputStructureBase64",
      "inputStructureBase64",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputStructureBase64"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "InputStructureBase64Response"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/MFSearch",
      "mFSearch",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "MFSearch"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "MFSearchResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/ScoreMatrix",
      "scoreMatrix",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "ScoreMatrix"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "ScoreMatrixResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/SimilaritySearch2D",
      "similaritySearch2D",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "SimilaritySearch2D"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "SimilaritySearch2DResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/Standardize",
      "standardize",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "Standardize"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "StandardizeResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/SubstructureSearch",
      "substructureSearch",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "SubstructureSearch"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "SubstructureSearchResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://pubchem.ncbi.nlm.nih.gov/SuperstructureSearch",
      "superstructureSearch",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "SuperstructureSearch"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://pubchem.ncbi.nlm.nih.gov/", "SuperstructureSearchResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = DefaultMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = DefaultMappingRegistry::LiteralRegistry
    init_methods
  end

  def wait_complete(key)
    anyKey = AnyKeyType.new(key)
    status = getOperationStatus(anyKey)
    while status.status == StatusType::EStatus_Queued or status.status == StatusType::EStatus_Running
      sleep(10)
      status  = getOperationStatus(anyKey)
    end
    if status.status != StatusType::EStatus_HitLimit and status.status != StatusType::EStatus_TimeLimit and status.status != StatusType::EStatus_Success
      return getStatusMessage(anyKey).message
    else
      key
    end
  end

private

  def init_methods
    Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        add_document_operation(*definitions)
      else
        add_rpc_operation(*definitions)
        qname = definitions[0]
        name = definitions[2]
        if qname.name != name and qname.name.capitalize == name.capitalize
          ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
            __send__(name, *arg)
          end
        end
      end
    end
  end
end

