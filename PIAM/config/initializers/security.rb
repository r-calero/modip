# Rails 3.2.8 is affected by CVE-2013-0156: XML request parameters may carry
# YAML and Symbol values, which allows remote code execution. MODIP does not
# accept XML requests, so XML parameter parsing is turned off, and YAML/Symbol
# conversion is removed in case XML is parsed elsewhere. This is the official
# workaround published with the advisory (fixed in Rails 3.2.11).
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
ActiveSupport::XmlMini::PARSING.delete("symbol")
ActiveSupport::XmlMini::PARSING.delete("yaml")
