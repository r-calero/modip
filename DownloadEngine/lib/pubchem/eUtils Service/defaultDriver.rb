require 'pubchem/eUtils Service/default'
require 'pubchem/eUtils Service/defaultMappingRegistry'
require 'soap/rpc/driver'

class EUtilsServiceSoap < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://eutils.ncbi.nlm.nih.gov/soap/v2.0/soap_adapter_2_0.cgi"

  Methods = [
    [ "egquery",
      "run_eGquery",
      [ ["in", "request", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/egquery", "eGqueryRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/egquery", "Result"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "einfo",
      "run_eInfo",
      [ ["in", "request", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/einfo", "eInfoRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/einfo", "eInfoResult"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "esearch",
      "run_eSearch",
      [ ["in", "request", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/esearch", "eSearchRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/esearch", "eSearchResult"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "esummary",
      "run_eSummary",
      [ ["in", "request", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/esummary", "eSummaryRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/esummary", "eSummaryResult"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "elink",
      "run_eLink",
      [ ["in", "request", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/elink", "eLinkRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/elink", "eLinkResult"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "espell",
      "run_eSpell",
      [ ["in", "request", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/espell", "eSpellRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/espell", "eSpellResult"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "epost",
      "run_ePost",
      [ ["in", "request", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/epost", "ePostRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://www.ncbi.nlm.nih.gov/soap/eutils/epost", "ePostResult"]] ],
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

