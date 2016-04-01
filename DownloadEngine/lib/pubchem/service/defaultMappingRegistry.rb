require 'rubygems'
gem 'soap4r'
require 'pubchem/service/default'
require 'soap/mapping'

module DefaultMappingRegistry
  #EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  # LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsPubchemNcbiNlmNihGov = "http://pubchem.ncbi.nlm.nih.gov/"

  EncodedRegistry.register(
    :class => ArrayOfInt,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ArrayOfInt"),
    :schema_element => [
      ["int", "SOAP::SOAPInt[]", [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => EntrezKey,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "EntrezKey"),
    :schema_element => [
      ["db", "SOAP::SOAPString"],
      ["key", "SOAP::SOAPString"],
      ["webenv", "SOAP::SOAPString"]
    ]
  )

  EncodedRegistry.register(
    :class => IdentitySearchOptions,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IdentitySearchOptions"),
    :schema_element => [
      ["eIdentity", "IdentityType"],
      ["toWebEnv", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ToWebEnv")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LimitsType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "LimitsType"),
    :schema_element => [
      ["seconds", "SOAP::SOAPInt", [0, 1]],
      ["maxRecords", "SOAP::SOAPInt", [0, 1]],
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => StructureSearchOptions,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "StructureSearchOptions"),
    :schema_element => [
      ["matchIsotopes", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "MatchIsotopes")], [0, 1]],
      ["matchCharges", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "MatchCharges")], [0, 1]],
      ["matchTautomers", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "MatchTautomers")], [0, 1]],
      ["ringsNotEmbedded", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "RingsNotEmbedded")], [0, 1]],
      ["singeDoubleBondsMatch", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SingeDoubleBondsMatch")], [0, 1]],
      ["chainsMatchRings", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ChainsMatchRings")], [0, 1]],
      ["stripHydrogen", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StripHydrogen")], [0, 1]],
      ["eStereo", "StereoType", [0, 1]],
      ["toWebEnv", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ToWebEnv")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => SimilaritySearchOptions,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "SimilaritySearchOptions"),
    :schema_element => [
      ["threshold", "SOAP::SOAPInt"],
      ["toWebEnv", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ToWebEnv")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => MFSearchOptions,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "MFSearchOptions"),
    :schema_element => [
      ["allowOtherElements", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AllowOtherElements")]],
      ["toWebEnv", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ToWebEnv")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => AnyKeyType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AnyKeyType"),
    :schema_element => [
      ["anyKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AnyKey")]]
    ]
  )

  EncodedRegistry.register(
    :class => DataBlobType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "DataBlobType"),
    :schema_element => [
      ["data", ["SOAP::SOAPBase64", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Data")]],
      ["blobFormat", ["BlobFormatType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "BlobFormat")], [0, 1]],
      ["eCompress", "CompressType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => AssayDescriptionType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayDescriptionType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Name")], [0, 1]],
      ["description", ["ArrayOfString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Description")], [0, 1]],
      ["protocol", ["ArrayOfString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Protocol")], [0, 1]],
      ["comment", ["ArrayOfString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Comment")], [0, 1]],
      ["numberOfTIDs", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "NumberOfTIDs")]],
      ["hasScore", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "HasScore")]],
      ["method", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Method")], [0, 1]],
      ["targets", ["ArrayOfTargets", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Targets")], [0, 1]],
      ["version", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Version")], [0, 1]],
      ["revision", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Revision")], [0, 1]],
      ["lastDataChange", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "LastDataChange")], [0, 1]],
      ["sIDCountAll", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountAll")], [0, 1]],
      ["sIDCountActive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountActive")], [0, 1]],
      ["sIDCountInactive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountInactive")], [0, 1]],
      ["sIDCountInconclusive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountInconclusive")], [0, 1]],
      ["sIDCountUnspecified", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountUnspecified")], [0, 1]],
      ["sIDCountProbe", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountProbe")], [0, 1]],
      ["cIDCountAll", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountAll")], [0, 1]],
      ["cIDCountActive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountActive")], [0, 1]],
      ["cIDCountInactive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountInactive")], [0, 1]],
      ["cIDCountInconclusive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountInconclusive")], [0, 1]],
      ["cIDCountUnspecified", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountUnspecified")], [0, 1]],
      ["cIDCountProbe", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountProbe")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => ArrayOfString,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ArrayOfString"),
    :schema_element => [
      ["string", "SOAP::SOAPString[]", [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => ArrayOfTargets,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ArrayOfTargets"),
    :schema_element => [
      ["target", ["AssayTargetType[]", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Target")], [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => AssayTargetType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayTargetType"),
    :schema_element => [
      ["gi", "SOAP::SOAPInt"],
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Name")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => ColumnDescriptionType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ColumnDescriptionType"),
    :schema_element => [
      ["heading", ["HeadingType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Heading")]],
      ["tID", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "TID")], [0, 1]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Name")]],
      ["description", ["ArrayOfString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Description")], [0, 1]],
      ["type", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Type")]],
      ["unit", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Unit")], [0, 1]],
      ["testedConcentration", ["TestedConcentrationType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "TestedConcentration")], [0, 1]],
      ["activeConcentration", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ActiveConcentration")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => TestedConcentrationType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "TestedConcentrationType"),
    :schema_element => [
      ["concentration", ["SOAP::SOAPDouble", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Concentration")]],
      ["unit", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Unit")]]
    ]
  )

  EncodedRegistry.register(
    :class => FormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "FormatType")
  )

  EncodedRegistry.register(
    :class => PCIDType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "PCIDType")
  )

  EncodedRegistry.register(
    :class => IdentityType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IdentityType")
  )

  EncodedRegistry.register(
    :class => StereoType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "StereoType")
  )

  EncodedRegistry.register(
    :class => StatusType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "StatusType")
  )

  EncodedRegistry.register(
    :class => CompressType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "CompressType")
  )

  EncodedRegistry.register(
    :class => BlobFormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "BlobFormatType")
  )

  EncodedRegistry.register(
    :class => HeadingType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "HeadingType")
  )

  EncodedRegistry.register(
    :class => AssayColumnsType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayColumnsType")
  )

  EncodedRegistry.register(
    :class => AssayOutcomeFilterType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayOutcomeFilterType")
  )

  EncodedRegistry.register(
    :class => AssayFormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayFormatType")
  )

  EncodedRegistry.register(
    :class => ScoreTypeType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ScoreTypeType")
  )

  EncodedRegistry.register(
    :class => MatrixFormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "MatrixFormatType")
  )

  EncodedRegistry.register(
    :class => IDOperationType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IDOperationType")
  )

  EncodedRegistry.register(
    :class => IDOutputFormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IDOutputFormatType")
  )

  LiteralRegistry.register(
    :class => ArrayOfInt,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ArrayOfInt"),
    :schema_element => [
      ["int", "SOAP::SOAPInt[]", [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => EntrezKey,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "EntrezKey"),
    :schema_element => [
      ["db", "SOAP::SOAPString"],
      ["key", "SOAP::SOAPString"],
      ["webenv", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => IdentitySearchOptions,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IdentitySearchOptions"),
    :schema_element => [
      ["eIdentity", "IdentityType"],
      ["toWebEnv", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ToWebEnv")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LimitsType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "LimitsType"),
    :schema_element => [
      ["seconds", "SOAP::SOAPInt", [0, 1]],
      ["maxRecords", "SOAP::SOAPInt", [0, 1]],
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => StructureSearchOptions,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "StructureSearchOptions"),
    :schema_element => [
      ["matchIsotopes", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "MatchIsotopes")], [0, 1]],
      ["matchCharges", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "MatchCharges")], [0, 1]],
      ["matchTautomers", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "MatchTautomers")], [0, 1]],
      ["ringsNotEmbedded", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "RingsNotEmbedded")], [0, 1]],
      ["singeDoubleBondsMatch", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SingeDoubleBondsMatch")], [0, 1]],
      ["chainsMatchRings", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ChainsMatchRings")], [0, 1]],
      ["stripHydrogen", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StripHydrogen")], [0, 1]],
      ["eStereo", "StereoType", [0, 1]],
      ["toWebEnv", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ToWebEnv")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => SimilaritySearchOptions,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "SimilaritySearchOptions"),
    :schema_element => [
      ["threshold", "SOAP::SOAPInt"],
      ["toWebEnv", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ToWebEnv")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => MFSearchOptions,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "MFSearchOptions"),
    :schema_element => [
      ["allowOtherElements", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AllowOtherElements")]],
      ["toWebEnv", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ToWebEnv")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => AnyKeyType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AnyKeyType"),
    :schema_element => [
      ["anyKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AnyKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => DataBlobType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "DataBlobType"),
    :schema_element => [
      ["data", ["SOAP::SOAPBase64", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Data")]],
      ["blobFormat", ["BlobFormatType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "BlobFormat")], [0, 1]],
      ["eCompress", "CompressType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => AssayDescriptionType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayDescriptionType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Name")], [0, 1]],
      ["description", ["ArrayOfString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Description")], [0, 1]],
      ["protocol", ["ArrayOfString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Protocol")], [0, 1]],
      ["comment", ["ArrayOfString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Comment")], [0, 1]],
      ["numberOfTIDs", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "NumberOfTIDs")]],
      ["hasScore", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "HasScore")]],
      ["method", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Method")], [0, 1]],
      ["targets", ["ArrayOfTargets", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Targets")], [0, 1]],
      ["version", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Version")], [0, 1]],
      ["revision", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Revision")], [0, 1]],
      ["lastDataChange", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "LastDataChange")], [0, 1]],
      ["sIDCountAll", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountAll")], [0, 1]],
      ["sIDCountActive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountActive")], [0, 1]],
      ["sIDCountInactive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountInactive")], [0, 1]],
      ["sIDCountInconclusive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountInconclusive")], [0, 1]],
      ["sIDCountUnspecified", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountUnspecified")], [0, 1]],
      ["sIDCountProbe", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SIDCountProbe")], [0, 1]],
      ["cIDCountAll", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountAll")], [0, 1]],
      ["cIDCountActive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountActive")], [0, 1]],
      ["cIDCountInactive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountInactive")], [0, 1]],
      ["cIDCountInconclusive", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountInconclusive")], [0, 1]],
      ["cIDCountUnspecified", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountUnspecified")], [0, 1]],
      ["cIDCountProbe", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CIDCountProbe")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfString,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ArrayOfString"),
    :schema_element => [
      ["string", "SOAP::SOAPString[]", [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfTargets,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ArrayOfTargets"),
    :schema_element => [
      ["target", ["AssayTargetType[]", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Target")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => AssayTargetType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayTargetType"),
    :schema_element => [
      ["gi", "SOAP::SOAPInt"],
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Name")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ColumnDescriptionType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ColumnDescriptionType"),
    :schema_element => [
      ["heading", ["HeadingType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Heading")]],
      ["tID", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "TID")], [0, 1]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Name")]],
      ["description", ["ArrayOfString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Description")], [0, 1]],
      ["type", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Type")]],
      ["unit", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Unit")], [0, 1]],
      ["testedConcentration", ["TestedConcentrationType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "TestedConcentration")], [0, 1]],
      ["activeConcentration", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ActiveConcentration")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => TestedConcentrationType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "TestedConcentrationType"),
    :schema_element => [
      ["concentration", ["SOAP::SOAPDouble", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Concentration")]],
      ["unit", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Unit")]]
    ]
  )

  LiteralRegistry.register(
    :class => FormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "FormatType")
  )

  LiteralRegistry.register(
    :class => PCIDType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "PCIDType")
  )

  LiteralRegistry.register(
    :class => IdentityType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IdentityType")
  )

  LiteralRegistry.register(
    :class => StereoType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "StereoType")
  )

  LiteralRegistry.register(
    :class => StatusType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "StatusType")
  )

  LiteralRegistry.register(
    :class => CompressType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "CompressType")
  )

  LiteralRegistry.register(
    :class => BlobFormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "BlobFormatType")
  )

  LiteralRegistry.register(
    :class => HeadingType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "HeadingType")
  )

  LiteralRegistry.register(
    :class => AssayColumnsType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayColumnsType")
  )

  LiteralRegistry.register(
    :class => AssayOutcomeFilterType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayOutcomeFilterType")
  )

  LiteralRegistry.register(
    :class => AssayFormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayFormatType")
  )

  LiteralRegistry.register(
    :class => ScoreTypeType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ScoreTypeType")
  )

  LiteralRegistry.register(
    :class => MatrixFormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "MatrixFormatType")
  )

  LiteralRegistry.register(
    :class => IDOperationType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IDOperationType")
  )

  LiteralRegistry.register(
    :class => IDOutputFormatType,
    :schema_type => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IDOutputFormatType")
  )

  LiteralRegistry.register(
    :class => InputStructure,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputStructure"),
    :schema_element => [
      ["structure", "SOAP::SOAPString"],
      ["format", "FormatType"]
    ]
  )

  LiteralRegistry.register(
    :class => InputStructureResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputStructureResponse"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => InputStructureBase64,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputStructureBase64"),
    :schema_element => [
      ["structure", "SOAP::SOAPBase64"],
      ["format", "FormatType"]
    ]
  )

  LiteralRegistry.register(
    :class => InputStructureBase64Response,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputStructureBase64Response"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => InputList,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputList"),
    :schema_element => [
      ["ids", "ArrayOfInt"],
      ["idType", "PCIDType"]
    ]
  )

  LiteralRegistry.register(
    :class => InputListResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputListResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => InputListString,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputListString"),
    :schema_element => [
      ["strids", "ArrayOfString"],
      ["idType", "PCIDType"],
      ["sourceName", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SourceName")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => InputListStringResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputListStringResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => InputListText,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputListText"),
    :schema_element => [
      ["ids", "SOAP::SOAPString"],
      ["idType", "PCIDType"]
    ]
  )

  LiteralRegistry.register(
    :class => InputListTextResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputListTextResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => InputEntrez,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputEntrez"),
    :schema_element => [
      ["entrezKey", ["EntrezKey", XSD::QName.new(NsPubchemNcbiNlmNihGov, "EntrezKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => InputEntrezResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputEntrezResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => IdentitySearch,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IdentitySearch"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]],
      ["idOptions", "IdentitySearchOptions"],
      ["limits", "LimitsType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => IdentitySearchResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IdentitySearchResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => SubstructureSearch,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "SubstructureSearch"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]],
      ["ssOptions", "StructureSearchOptions", [0, 1]],
      ["limits", "LimitsType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => SubstructureSearchResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "SubstructureSearchResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => SuperstructureSearch,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "SuperstructureSearch"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]],
      ["ssOptions", "StructureSearchOptions", [0, 1]],
      ["limits", "LimitsType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => SuperstructureSearchResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "SuperstructureSearchResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => SimilaritySearch2D,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "SimilaritySearch2D"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]],
      ["simOptions", "SimilaritySearchOptions"],
      ["limits", "LimitsType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => SimilaritySearch2DResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "SimilaritySearch2DResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => MFSearch,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "MFSearch"),
    :schema_element => [
      ["mF", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "MF")]],
      ["mfOptions", "MFSearchOptions", [0, 1]],
      ["limits", "LimitsType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => MFSearchResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "MFSearchResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => Standardize,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "Standardize"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => StandardizeResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "StandardizeResponse"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetStandardizedCID,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetStandardizedCID"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetStandardizedCIDResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetStandardizedCIDResponse"),
    :schema_element => [
      ["cID", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "CID")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetStandardizedStructure,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetStandardizedStructure"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]],
      ["format", "FormatType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetStandardizedStructureResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetStandardizedStructureResponse"),
    :schema_element => [
      ["structure", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => GetStandardizedStructureBase64,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetStandardizedStructureBase64"),
    :schema_element => [
      ["strKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "StrKey")]],
      ["format", "FormatType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetStandardizedStructureBase64Response,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetStandardizedStructureBase64Response"),
    :schema_element => [
      ["structure", "SOAP::SOAPBase64"]
    ]
  )

  LiteralRegistry.register(
    :class => AnyKeyType,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetOperationStatus"),
    :schema_element => [
      ["anyKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AnyKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetOperationStatusResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetOperationStatusResponse"),
    :schema_element => [
      ["status", "StatusType"]
    ]
  )

  LiteralRegistry.register(
    :class => AnyKeyType,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetStatusMessage"),
    :schema_element => [
      ["anyKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AnyKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetStatusMessageResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetStatusMessageResponse"),
    :schema_element => [
      ["message", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => GetListItemsCount,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetListItemsCount"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetListItemsCountResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetListItemsCountResponse"),
    :schema_element => [
      ["count", "SOAP::SOAPInt"]
    ]
  )

  LiteralRegistry.register(
    :class => GetEntrezKey,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetEntrezKey"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetEntrezKeyResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetEntrezKeyResponse"),
    :schema_element => [
      ["entrezKey", ["EntrezKey", XSD::QName.new(NsPubchemNcbiNlmNihGov, "EntrezKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetEntrezUrl,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetEntrezUrl"),
    :schema_element => [
      ["entrezKey", ["EntrezKey", XSD::QName.new(NsPubchemNcbiNlmNihGov, "EntrezKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetEntrezUrlResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetEntrezUrlResponse"),
    :schema_element => [
      ["url", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => Download,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "Download"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]],
      ["eFormat", "FormatType"],
      ["eCompress", "CompressType", [0, 1]],
      ["use3D", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Use3D")], [0, 1]],
      ["n3DConformers", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "N3DConformers")], [0, 1]],
      ["synchronousSingleRecord", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SynchronousSingleRecord")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => DownloadResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "DownloadResponse"),
    :schema_element => [
      ["downloadKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "DownloadKey")], [0, 1]],
      ["dataBlob", ["DataBlobType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "DataBlob")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetDownloadUrl,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetDownloadUrl"),
    :schema_element => [
      ["downloadKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "DownloadKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetDownloadUrlResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetDownloadUrlResponse"),
    :schema_element => [
      ["url", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => GetIDList,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetIDList"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]],
      ["start", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Start")], [0, 1]],
      ["count", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Count")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetIDListResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetIDListResponse"),
    :schema_element => [
      ["iDList", ["ArrayOfInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "IDList")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetAssayDescription,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetAssayDescription"),
    :schema_element => [
      ["aID", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AID")]],
      ["getVersion", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetVersion")], [0, 1]],
      ["getCounts", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetCounts")], [0, 1]],
      ["getFullDataBlob", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetFullDataBlob")], [0, 1]],
      ["eFormat", "FormatType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetAssayDescriptionResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetAssayDescriptionResponse"),
    :schema_element => [
      ["assayDescription", ["AssayDescriptionType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayDescription")], [0, 1]],
      ["dataBlob", ["DataBlobType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "DataBlob")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetAssayColumnDescription,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetAssayColumnDescription"),
    :schema_element => [
      ["aID", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AID")]],
      ["heading", ["HeadingType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Heading")]],
      ["tID", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "TID")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetAssayColumnDescriptionResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetAssayColumnDescriptionResponse"),
    :schema_element => [
      ["columnDescription", ["ColumnDescriptionType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ColumnDescription")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetAssayColumnDescriptions,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetAssayColumnDescriptions"),
    :schema_element => [
      ["aID", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AID")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetAssayColumnDescriptionsResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "GetAssayColumnDescriptionsResponse"),
    :schema_element => [
      ["columnDescription", ["ColumnDescriptionType[]", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ColumnDescription")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => InputAssay,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputAssay"),
    :schema_element => [
      ["aID", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AID")]],
      ["columns", ["AssayColumnsType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Columns")]],
      ["listKeyTIDs", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKeyTIDs")], [0, 1]],
      ["listKeySCIDs", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKeySCIDs")], [0, 1]],
      ["outcomeFilter", ["AssayOutcomeFilterType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "OutcomeFilter")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => InputAssayResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputAssayResponse"),
    :schema_element => [
      ["assayKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => AssayDownload,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayDownload"),
    :schema_element => [
      ["assayKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayKey")]],
      ["assayFormat", ["AssayFormatType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayFormat")]],
      ["eCompress", "CompressType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => AssayDownloadResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "AssayDownloadResponse"),
    :schema_element => [
      ["downloadKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "DownloadKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => ScoreMatrix,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ScoreMatrix"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")]],
      ["secondaryListKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "SecondaryListKey")], [0, 1]],
      ["scoreType", ["ScoreTypeType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ScoreType")]],
      ["matrixFormat", ["MatrixFormatType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "MatrixFormat")]],
      ["eCompress", "CompressType", [0, 1]],
      ["n3DConformers", ["SOAP::SOAPInt", XSD::QName.new(NsPubchemNcbiNlmNihGov, "N3DConformers")], [0, 1]],
      ["no3DParent", ["SOAP::SOAPBoolean", XSD::QName.new(NsPubchemNcbiNlmNihGov, "No3DParent")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ScoreMatrixResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "ScoreMatrixResponse"),
    :schema_element => [
      ["downloadKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "DownloadKey")]]
    ]
  )

  LiteralRegistry.register(
    :class => IDExchange,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IDExchange"),
    :schema_element => [
      ["inputListKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "InputListKey")]],
      ["operation", ["IDOperationType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "Operation")]],
      ["outputType", ["PCIDType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "OutputType")]],
      ["outputSourceName", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "OutputSourceName")], [0, 1]],
      ["outputFormat", ["IDOutputFormatType", XSD::QName.new(NsPubchemNcbiNlmNihGov, "OutputFormat")]],
      ["toWebEnv", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ToWebEnv")], [0, 1]],
      ["eCompress", "CompressType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => IDExchangeResponse,
    :schema_name => XSD::QName.new(NsPubchemNcbiNlmNihGov, "IDExchangeResponse"),
    :schema_element => [
      ["listKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "ListKey")], [0, 1]],
      ["downloadKey", ["SOAP::SOAPString", XSD::QName.new(NsPubchemNcbiNlmNihGov, "DownloadKey")], [0, 1]]
    ]
  )
end
