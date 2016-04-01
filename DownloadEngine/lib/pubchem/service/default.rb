require 'xsd/qname'
require 'drb'

# {http://pubchem.ncbi.nlm.nih.gov/}ArrayOfInt
class ArrayOfInt < ::Array
end

# {http://pubchem.ncbi.nlm.nih.gov/}EntrezKey
#   db - SOAP::SOAPString
#   key - SOAP::SOAPString
#   webenv - SOAP::SOAPString
class EntrezKey
  attr_accessor :db
  attr_accessor :key
  attr_accessor :webenv

  def initialize(db = nil, key = nil, webenv = nil)
    @db = db
    @key = key
    @webenv = webenv
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}IdentitySearchOptions
#   eIdentity - IdentityType
#   toWebEnv - SOAP::SOAPString
class IdentitySearchOptions
  attr_accessor :eIdentity
  attr_accessor :toWebEnv

  def initialize(eIdentity = nil, toWebEnv = nil)
    @eIdentity = eIdentity
    @toWebEnv = toWebEnv
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}LimitsType
#   seconds - SOAP::SOAPInt
#   maxRecords - SOAP::SOAPInt
#   listKey - SOAP::SOAPString
class LimitsType
  attr_accessor :seconds
  attr_accessor :maxRecords
  attr_accessor :listKey

  def initialize(seconds = nil, maxRecords = nil, listKey = nil)
    @seconds = seconds
    @maxRecords = maxRecords
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}StructureSearchOptions
#   matchIsotopes - SOAP::SOAPBoolean
#   matchCharges - SOAP::SOAPBoolean
#   matchTautomers - SOAP::SOAPBoolean
#   ringsNotEmbedded - SOAP::SOAPBoolean
#   singeDoubleBondsMatch - SOAP::SOAPBoolean
#   chainsMatchRings - SOAP::SOAPBoolean
#   stripHydrogen - SOAP::SOAPBoolean
#   eStereo - StereoType
#   toWebEnv - SOAP::SOAPString
class StructureSearchOptions
  attr_accessor :matchIsotopes
  attr_accessor :matchCharges
  attr_accessor :matchTautomers
  attr_accessor :ringsNotEmbedded
  attr_accessor :singeDoubleBondsMatch
  attr_accessor :chainsMatchRings
  attr_accessor :stripHydrogen
  attr_accessor :eStereo
  attr_accessor :toWebEnv

  def initialize(matchIsotopes = nil, matchCharges = nil, matchTautomers = nil, ringsNotEmbedded = nil, singeDoubleBondsMatch = nil, chainsMatchRings = nil, stripHydrogen = nil, eStereo = nil, toWebEnv = nil)
    @matchIsotopes = matchIsotopes
    @matchCharges = matchCharges
    @matchTautomers = matchTautomers
    @ringsNotEmbedded = ringsNotEmbedded
    @singeDoubleBondsMatch = singeDoubleBondsMatch
    @chainsMatchRings = chainsMatchRings
    @stripHydrogen = stripHydrogen
    @eStereo = eStereo
    @toWebEnv = toWebEnv
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}SimilaritySearchOptions
#   threshold - SOAP::SOAPInt
#   toWebEnv - SOAP::SOAPString
class SimilaritySearchOptions
  attr_accessor :threshold
  attr_accessor :toWebEnv

  def initialize(threshold = nil, toWebEnv = nil)
    @threshold = threshold
    @toWebEnv = toWebEnv
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}MFSearchOptions
#   allowOtherElements - SOAP::SOAPBoolean
#   toWebEnv - SOAP::SOAPString
class MFSearchOptions
  attr_accessor :allowOtherElements
  attr_accessor :toWebEnv

  def initialize(allowOtherElements = nil, toWebEnv = nil)
    @allowOtherElements = allowOtherElements
    @toWebEnv = toWebEnv
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}AnyKeyType
#   anyKey - SOAP::SOAPString
class AnyKeyType
  attr_accessor :anyKey

  def initialize(anyKey = nil)
    @anyKey = anyKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}DataBlobType
#   data - SOAP::SOAPBase64
#   blobFormat - BlobFormatType
#   eCompress - CompressType
class DataBlobType
  attr_accessor :data
  attr_accessor :blobFormat
  attr_accessor :eCompress

  def initialize(data = nil, blobFormat = nil, eCompress = nil)
    @data = data
    @blobFormat = blobFormat
    @eCompress = eCompress
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}AssayDescriptionType
#   name - SOAP::SOAPString
#   description - ArrayOfString
#   protocol - ArrayOfString
#   comment - ArrayOfString
#   numberOfTIDs - SOAP::SOAPInt
#   hasScore - SOAP::SOAPBoolean
#   method - SOAP::SOAPString
#   targets - ArrayOfTargets
#   version - SOAP::SOAPInt
#   revision - SOAP::SOAPInt
#   lastDataChange - SOAP::SOAPInt
#   sIDCountAll - SOAP::SOAPInt
#   sIDCountActive - SOAP::SOAPInt
#   sIDCountInactive - SOAP::SOAPInt
#   sIDCountInconclusive - SOAP::SOAPInt
#   sIDCountUnspecified - SOAP::SOAPInt
#   sIDCountProbe - SOAP::SOAPInt
#   cIDCountAll - SOAP::SOAPInt
#   cIDCountActive - SOAP::SOAPInt
#   cIDCountInactive - SOAP::SOAPInt
#   cIDCountInconclusive - SOAP::SOAPInt
#   cIDCountUnspecified - SOAP::SOAPInt
#   cIDCountProbe - SOAP::SOAPInt
class AssayDescriptionType
	include DRbUndumped
  attr_accessor :name
  attr_accessor :description
  attr_accessor :protocol
  attr_accessor :comment
  attr_accessor :numberOfTIDs
  attr_accessor :hasScore
  attr_accessor :method #provisional -> method
  attr_accessor :targets
  attr_accessor :version
  attr_accessor :revision
  attr_accessor :lastDataChange
  attr_accessor :sIDCountAll
  attr_accessor :sIDCountActive
  attr_accessor :sIDCountInactive
  attr_accessor :sIDCountInconclusive
  attr_accessor :sIDCountUnspecified
  attr_accessor :sIDCountProbe
  attr_accessor :cIDCountAll
  attr_accessor :cIDCountActive
  attr_accessor :cIDCountInactive
  attr_accessor :cIDCountInconclusive
  attr_accessor :cIDCountUnspecified
  attr_accessor :cIDCountProbe

  def initialize(name = nil, description = nil, protocol = nil, comment = nil, numberOfTIDs = nil, hasScore = nil, method = nil, targets = nil, version = nil, revision = nil, lastDataChange = nil, sIDCountAll = nil, sIDCountActive = nil, sIDCountInactive = nil, sIDCountInconclusive = nil, sIDCountUnspecified = nil, sIDCountProbe = nil, cIDCountAll = nil, cIDCountActive = nil, cIDCountInactive = nil, cIDCountInconclusive = nil, cIDCountUnspecified = nil, cIDCountProbe = nil)
    @name = name
    @description = description
    @protocol = protocol
    @comment = comment
    @numberOfTIDs = numberOfTIDs
    @hasScore = hasScore
    @method = method
    @targets = targets
    @version = version
    @revision = revision
    @lastDataChange = lastDataChange
    @sIDCountAll = sIDCountAll
    @sIDCountActive = sIDCountActive
    @sIDCountInactive = sIDCountInactive
    @sIDCountInconclusive = sIDCountInconclusive
    @sIDCountUnspecified = sIDCountUnspecified
    @sIDCountProbe = sIDCountProbe
    @cIDCountAll = cIDCountAll
    @cIDCountActive = cIDCountActive
    @cIDCountInactive = cIDCountInactive
    @cIDCountInconclusive = cIDCountInconclusive
    @cIDCountUnspecified = cIDCountUnspecified
    @cIDCountProbe = cIDCountProbe
  end
  
  def assay_method #problema al llamar el atributo method (confunde con llamada a un metodo : assay_description.method (ArgumentError: wrong number of arguments (0 for 1)))
	@method
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}ArrayOfString
class ArrayOfString < ::Array
  include DRbUndumped

end

# {http://pubchem.ncbi.nlm.nih.gov/}ArrayOfTargets
class ArrayOfTargets < ::Array
end

# {http://pubchem.ncbi.nlm.nih.gov/}AssayTargetType
#   gi - SOAP::SOAPInt
#   name - SOAP::SOAPString
class AssayTargetType
  attr_accessor :gi
  attr_accessor :name

  def initialize(gi = nil, name = nil)
    @gi = gi
    @name = name
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}ColumnDescriptionType
#   heading - HeadingType
#   tID - SOAP::SOAPInt
#   name - SOAP::SOAPString
#   description - ArrayOfString
#   type - SOAP::SOAPString
#   unit - SOAP::SOAPString
#   testedConcentration - TestedConcentrationType
#   activeConcentration - SOAP::SOAPBoolean
class ColumnDescriptionType
	include DRbUndumped
  attr_accessor :heading
  attr_accessor :tID
  attr_accessor :name
  attr_accessor :description
  attr_accessor :type # provisional -> type
  attr_accessor :unit
  attr_accessor :testedConcentration
  attr_accessor :activeConcentration

  def initialize(heading = nil, tID = nil, name = nil, description = nil, type = nil, unit = nil, testedConcentration = nil, activeConcentration = nil)
    @heading = heading
    @tID = tID
    @name = name
    @description = description
    @type = type
    @unit = unit
    @testedConcentration = testedConcentration
    @activeConcentration = activeConcentration
  end
  
  def column_type #problema, confunde con el tipo de la clase
	@type
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}TestedConcentrationType
#   concentration - SOAP::SOAPDouble
#   unit - SOAP::SOAPString
class TestedConcentrationType
  include DRbUndumped
  attr_accessor :concentration
  attr_accessor :unit

  def initialize(concentration = nil, unit = nil)
    @concentration = concentration
    @unit = unit
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}FormatType
class FormatType < ::String
  EFormat_ASNB = FormatType.new("eFormat_ASNB")
  EFormat_ASNT = FormatType.new("eFormat_ASNT")
  EFormat_Image = FormatType.new("eFormat_Image")
  EFormat_InChI = FormatType.new("eFormat_InChI")
  EFormat_SDF = FormatType.new("eFormat_SDF")
  EFormat_SMILES = FormatType.new("eFormat_SMILES")
  EFormat_Thumbnail = FormatType.new("eFormat_Thumbnail")
  EFormat_XML = FormatType.new("eFormat_XML")
end

# {http://pubchem.ncbi.nlm.nih.gov/}PCIDType
class PCIDType < ::String
  EID_AID = PCIDType.new("eID_AID")
  EID_CID = PCIDType.new("eID_CID")
  EID_ConformerID = PCIDType.new("eID_ConformerID")
  EID_InChI = PCIDType.new("eID_InChI")
  EID_InChIKey = PCIDType.new("eID_InChIKey")
  EID_SID = PCIDType.new("eID_SID")
  EID_SourceID = PCIDType.new("eID_SourceID")
  EID_TID = PCIDType.new("eID_TID")
end

# {http://pubchem.ncbi.nlm.nih.gov/}IdentityType
class IdentityType < ::String
  EIdentity_AnyTautomer = IdentityType.new("eIdentity_AnyTautomer")
  EIdentity_SameConnectivity = IdentityType.new("eIdentity_SameConnectivity")
  EIdentity_SameIsotope = IdentityType.new("eIdentity_SameIsotope")
  EIdentity_SameIsotopeNonconflictStereo = IdentityType.new("eIdentity_SameIsotopeNonconflictStereo")
  EIdentity_SameNonconflictStereo = IdentityType.new("eIdentity_SameNonconflictStereo")
  EIdentity_SameStereo = IdentityType.new("eIdentity_SameStereo")
  EIdentity_SameStereoIsotope = IdentityType.new("eIdentity_SameStereoIsotope")
end

# {http://pubchem.ncbi.nlm.nih.gov/}StereoType
class StereoType < ::String
  EStereo_Exact = StereoType.new("eStereo_Exact")
  EStereo_Ignore = StereoType.new("eStereo_Ignore")
  EStereo_NonConflicting = StereoType.new("eStereo_NonConflicting")
  EStereo_Relative = StereoType.new("eStereo_Relative")
end

# {http://pubchem.ncbi.nlm.nih.gov/}StatusType
class StatusType < ::String
  EStatus_DataError = StatusType.new("eStatus_DataError")
  EStatus_HitLimit = StatusType.new("eStatus_HitLimit")
  EStatus_InputError = StatusType.new("eStatus_InputError")
  EStatus_Queued = StatusType.new("eStatus_Queued")
  EStatus_Running = StatusType.new("eStatus_Running")
  EStatus_ServerError = StatusType.new("eStatus_ServerError")
  EStatus_Stopped = StatusType.new("eStatus_Stopped")
  EStatus_Success = StatusType.new("eStatus_Success")
  EStatus_TimeLimit = StatusType.new("eStatus_TimeLimit")
  EStatus_Unknown = StatusType.new("eStatus_Unknown")
end

# {http://pubchem.ncbi.nlm.nih.gov/}CompressType
class CompressType < ::String
  ECompress_BZip2 = CompressType.new("eCompress_BZip2")
  ECompress_GZip = CompressType.new("eCompress_GZip")
  ECompress_None = CompressType.new("eCompress_None")
end

# {http://pubchem.ncbi.nlm.nih.gov/}BlobFormatType
class BlobFormatType < ::String
  EBlobFormat_ASNB = BlobFormatType.new("eBlobFormat_ASNB")
  EBlobFormat_ASNT = BlobFormatType.new("eBlobFormat_ASNT")
  EBlobFormat_CSV = BlobFormatType.new("eBlobFormat_CSV")
  EBlobFormat_HTML = BlobFormatType.new("eBlobFormat_HTML")
  EBlobFormat_Other = BlobFormatType.new("eBlobFormat_Other")
  EBlobFormat_PNG = BlobFormatType.new("eBlobFormat_PNG")
  EBlobFormat_SDF = BlobFormatType.new("eBlobFormat_SDF")
  EBlobFormat_Text = BlobFormatType.new("eBlobFormat_Text")
  EBlobFormat_Unspecified = BlobFormatType.new("eBlobFormat_Unspecified")
  EBlobFormat_XML = BlobFormatType.new("eBlobFormat_XML")
end

# {http://pubchem.ncbi.nlm.nih.gov/}HeadingType
class HeadingType < ::String
  include DRbUndumped
  Outcome = HeadingType.new("outcome")
  Score = HeadingType.new("score")
  TID = HeadingType.new("TID")
end

# {http://pubchem.ncbi.nlm.nih.gov/}AssayColumnsType
class AssayColumnsType < ::String
  EAssayColumns_Complete = AssayColumnsType.new("eAssayColumns_Complete")
  EAssayColumns_Concise = AssayColumnsType.new("eAssayColumns_Concise")
  EAssayColumns_TIDs = AssayColumnsType.new("eAssayColumns_TIDs")
end

# {http://pubchem.ncbi.nlm.nih.gov/}AssayOutcomeFilterType
class AssayOutcomeFilterType < ::String
  EAssayOutcome_Active = AssayOutcomeFilterType.new("eAssayOutcome_Active")
  EAssayOutcome_All = AssayOutcomeFilterType.new("eAssayOutcome_All")
  EAssayOutcome_Inactive = AssayOutcomeFilterType.new("eAssayOutcome_Inactive")
  EAssayOutcome_Inconclusive = AssayOutcomeFilterType.new("eAssayOutcome_Inconclusive")
  EAssayOutcome_Unspecified = AssayOutcomeFilterType.new("eAssayOutcome_Unspecified")
end

# {http://pubchem.ncbi.nlm.nih.gov/}AssayFormatType
class AssayFormatType < ::String
  EAssayFormat_ASN_Binary = AssayFormatType.new("eAssayFormat_ASN_Binary")
  EAssayFormat_ASN_Text = AssayFormatType.new("eAssayFormat_ASN_Text")
  EAssayFormat_CSV = AssayFormatType.new("eAssayFormat_CSV")
  EAssayFormat_XML = AssayFormatType.new("eAssayFormat_XML")
end

# {http://pubchem.ncbi.nlm.nih.gov/}ScoreTypeType
class ScoreTypeType < ::String
  EScoreType_FeatureOpt3D = ScoreTypeType.new("eScoreType_FeatureOpt3D")
  EScoreType_ShapeOpt3D = ScoreTypeType.new("eScoreType_ShapeOpt3D")
  EScoreType_Sim2DSubs = ScoreTypeType.new("eScoreType_Sim2DSubs")
end

# {http://pubchem.ncbi.nlm.nih.gov/}MatrixFormatType
class MatrixFormatType < ::String
  EMatrixFormat_CSV = MatrixFormatType.new("eMatrixFormat_CSV")
  EMatrixFormat_IdIdScore = MatrixFormatType.new("eMatrixFormat_IdIdScore")
end

# {http://pubchem.ncbi.nlm.nih.gov/}IDOperationType
class IDOperationType < ::String
  EIDOperation_Same = IDOperationType.new("eIDOperation_Same")
  EIDOperation_SameConnectivity = IDOperationType.new("eIDOperation_SameConnectivity")
  EIDOperation_SameIsotope = IDOperationType.new("eIDOperation_SameIsotope")
  EIDOperation_SameParent = IDOperationType.new("eIDOperation_SameParent")
  EIDOperation_SameParentConnectivity = IDOperationType.new("eIDOperation_SameParentConnectivity")
  EIDOperation_SameParentIsotope = IDOperationType.new("eIDOperation_SameParentIsotope")
  EIDOperation_SameParentStereo = IDOperationType.new("eIDOperation_SameParentStereo")
  EIDOperation_SameStereo = IDOperationType.new("eIDOperation_SameStereo")
  EIDOperation_Similar2D = IDOperationType.new("eIDOperation_Similar2D")
  EIDOperation_Similar3D = IDOperationType.new("eIDOperation_Similar3D")
end

# {http://pubchem.ncbi.nlm.nih.gov/}IDOutputFormatType
class IDOutputFormatType < ::String
  EIDOutputFormat_Entrez = IDOutputFormatType.new("eIDOutputFormat_Entrez")
  EIDOutputFormat_FileList = IDOutputFormatType.new("eIDOutputFormat_FileList")
  EIDOutputFormat_FilePair = IDOutputFormatType.new("eIDOutputFormat_FilePair")
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputStructure
#   structure - SOAP::SOAPString
#   format - FormatType
class InputStructure
  attr_accessor :structure
  attr_accessor :format

  def initialize(structure = nil, format = nil)
    @structure = structure
    @format = format
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputStructureResponse
#   strKey - SOAP::SOAPString
class InputStructureResponse
  attr_accessor :strKey

  def initialize(strKey = nil)
    @strKey = strKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputStructureBase64
#   structure - SOAP::SOAPBase64
#   format - FormatType
class InputStructureBase64
  attr_accessor :structure
  attr_accessor :format

  def initialize(structure = nil, format = nil)
    @structure = structure
    @format = format
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputStructureBase64Response
#   strKey - SOAP::SOAPString
class InputStructureBase64Response
  attr_accessor :strKey

  def initialize(strKey = nil)
    @strKey = strKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputList
#   ids - ArrayOfInt
#   idType - PCIDType
class InputList
  attr_accessor :ids
  attr_accessor :idType

  def initialize(ids = nil, idType = nil)
    @ids = ids
    @idType = idType
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputListResponse
#   listKey - SOAP::SOAPString
class InputListResponse
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputListString
#   strids - ArrayOfString
#   idType - PCIDType
#   sourceName - SOAP::SOAPString
class InputListString
  attr_accessor :strids
  attr_accessor :idType
  attr_accessor :sourceName

  def initialize(strids = nil, idType = nil, sourceName = nil)
    @strids = strids
    @idType = idType
    @sourceName = sourceName
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputListStringResponse
#   listKey - SOAP::SOAPString
class InputListStringResponse
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputListText
#   ids - SOAP::SOAPString
#   idType - PCIDType
class InputListText
  attr_accessor :ids
  attr_accessor :idType

  def initialize(ids = nil, idType = nil)
    @ids = ids
    @idType = idType
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputListTextResponse
#   listKey - SOAP::SOAPString
class InputListTextResponse
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputEntrez
#   entrezKey - EntrezKey
class InputEntrez
  attr_accessor :entrezKey

  def initialize(entrezKey = nil)
    @entrezKey = entrezKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputEntrezResponse
#   listKey - SOAP::SOAPString
class InputEntrezResponse
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}IdentitySearch
#   strKey - SOAP::SOAPString
#   idOptions - IdentitySearchOptions
#   limits - LimitsType
class IdentitySearch
  attr_accessor :strKey
  attr_accessor :idOptions
  attr_accessor :limits

  def initialize(strKey = nil, idOptions = nil, limits = nil)
    @strKey = strKey
    @idOptions = idOptions
    @limits = limits
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}IdentitySearchResponse
#   listKey - SOAP::SOAPString
class IdentitySearchResponse
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}SubstructureSearch
#   strKey - SOAP::SOAPString
#   ssOptions - StructureSearchOptions
#   limits - LimitsType
class SubstructureSearch
  attr_accessor :strKey
  attr_accessor :ssOptions
  attr_accessor :limits

  def initialize(strKey = nil, ssOptions = nil, limits = nil)
    @strKey = strKey
    @ssOptions = ssOptions
    @limits = limits
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}SubstructureSearchResponse
#   listKey - SOAP::SOAPString
class SubstructureSearchResponse
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}SuperstructureSearch
#   strKey - SOAP::SOAPString
#   ssOptions - StructureSearchOptions
#   limits - LimitsType
class SuperstructureSearch
  attr_accessor :strKey
  attr_accessor :ssOptions
  attr_accessor :limits

  def initialize(strKey = nil, ssOptions = nil, limits = nil)
    @strKey = strKey
    @ssOptions = ssOptions
    @limits = limits
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}SuperstructureSearchResponse
#   listKey - SOAP::SOAPString
class SuperstructureSearchResponse
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}SimilaritySearch2D
#   strKey - SOAP::SOAPString
#   simOptions - SimilaritySearchOptions
#   limits - LimitsType
class SimilaritySearch2D
  attr_accessor :strKey
  attr_accessor :simOptions
  attr_accessor :limits

  def initialize(strKey = nil, simOptions = nil, limits = nil)
    @strKey = strKey
    @simOptions = simOptions
    @limits = limits
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}SimilaritySearch2DResponse
#   listKey - SOAP::SOAPString
class SimilaritySearch2DResponse
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}MFSearch
#   mF - SOAP::SOAPString
#   mfOptions - MFSearchOptions
#   limits - LimitsType
class MFSearch
  attr_accessor :mF
  attr_accessor :mfOptions
  attr_accessor :limits

  def initialize(mF = nil, mfOptions = nil, limits = nil)
    @mF = mF
    @mfOptions = mfOptions
    @limits = limits
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}MFSearchResponse
#   listKey - SOAP::SOAPString
class MFSearchResponse
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}Standardize
#   strKey - SOAP::SOAPString
class Standardize
  attr_accessor :strKey

  def initialize(strKey = nil)
    @strKey = strKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}StandardizeResponse
#   strKey - SOAP::SOAPString
class StandardizeResponse
  attr_accessor :strKey

  def initialize(strKey = nil)
    @strKey = strKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetStandardizedCID
#   strKey - SOAP::SOAPString
class GetStandardizedCID
  attr_accessor :strKey

  def initialize(strKey = nil)
    @strKey = strKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetStandardizedCIDResponse
#   cID - SOAP::SOAPInt
class GetStandardizedCIDResponse
  attr_accessor :cID

  def initialize(cID = nil)
    @cID = cID
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetStandardizedStructure
#   strKey - SOAP::SOAPString
#   format - FormatType
class GetStandardizedStructure
  attr_accessor :strKey
  attr_accessor :format

  def initialize(strKey = nil, format = nil)
    @strKey = strKey
    @format = format
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetStandardizedStructureResponse
#   structure - SOAP::SOAPString
class GetStandardizedStructureResponse
  attr_accessor :structure

  def initialize(structure = nil)
    @structure = structure
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetStandardizedStructureBase64
#   strKey - SOAP::SOAPString
#   format - FormatType
class GetStandardizedStructureBase64
  attr_accessor :strKey
  attr_accessor :format

  def initialize(strKey = nil, format = nil)
    @strKey = strKey
    @format = format
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetStandardizedStructureBase64Response
#   structure - SOAP::SOAPBase64
class GetStandardizedStructureBase64Response
  attr_accessor :structure

  def initialize(structure = nil)
    @structure = structure
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetOperationStatusResponse
#   status - StatusType
class GetOperationStatusResponse
  attr_accessor :status

  def initialize(status = nil)
    @status = status
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetStatusMessageResponse
#   message - SOAP::SOAPString
class GetStatusMessageResponse
  attr_accessor :message

  def initialize(message = nil)
    @message = message
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetListItemsCount
#   listKey - SOAP::SOAPString
class GetListItemsCount
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetListItemsCountResponse
#   count - SOAP::SOAPInt
class GetListItemsCountResponse
  attr_accessor :count

  def initialize(count = nil)
    @count = count
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetEntrezKey
#   listKey - SOAP::SOAPString
class GetEntrezKey
  attr_accessor :listKey

  def initialize(listKey = nil)
    @listKey = listKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetEntrezKeyResponse
#   entrezKey - EntrezKey
class GetEntrezKeyResponse
  attr_accessor :entrezKey

  def initialize(entrezKey = nil)
    @entrezKey = entrezKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetEntrezUrl
#   entrezKey - EntrezKey
class GetEntrezUrl
  attr_accessor :entrezKey

  def initialize(entrezKey = nil)
    @entrezKey = entrezKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetEntrezUrlResponse
#   url - SOAP::SOAPString
class GetEntrezUrlResponse
  attr_accessor :url

  def initialize(url = nil)
    @url = url
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}Download
#   listKey - SOAP::SOAPString
#   eFormat - FormatType
#   eCompress - CompressType
#   use3D - SOAP::SOAPBoolean
#   n3DConformers - SOAP::SOAPInt
#   synchronousSingleRecord - SOAP::SOAPBoolean
class Download
  attr_accessor :listKey
  attr_accessor :eFormat
  attr_accessor :eCompress
  attr_accessor :use3D
  attr_accessor :n3DConformers
  attr_accessor :synchronousSingleRecord

  def initialize(listKey = nil, eFormat = nil, eCompress = nil, use3D = nil, n3DConformers = nil, synchronousSingleRecord = nil)
    @listKey = listKey
    @eFormat = eFormat
    @eCompress = eCompress
    @use3D = use3D
    @n3DConformers = n3DConformers
    @synchronousSingleRecord = synchronousSingleRecord
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}DownloadResponse
#   downloadKey - SOAP::SOAPString
#   dataBlob - DataBlobType
class DownloadResponse
  attr_accessor :downloadKey
  attr_accessor :dataBlob

  def initialize(downloadKey = nil, dataBlob = nil)
    @downloadKey = downloadKey
    @dataBlob = dataBlob
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetDownloadUrl
#   downloadKey - SOAP::SOAPString
class GetDownloadUrl
  attr_accessor :downloadKey

  def initialize(downloadKey = nil)
    @downloadKey = downloadKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetDownloadUrlResponse
#   url - SOAP::SOAPString
class GetDownloadUrlResponse
  attr_accessor :url

  def initialize(url = nil)
    @url = url
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetIDList
#   listKey - SOAP::SOAPString
#   start - SOAP::SOAPInt
#   count - SOAP::SOAPInt
class GetIDList
  attr_accessor :listKey
  attr_accessor :start
  attr_accessor :count

  def initialize(listKey = nil, start = nil, count = nil)
    @listKey = listKey
    @start = start
    @count = count
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetIDListResponse
#   iDList - ArrayOfInt
class GetIDListResponse
  attr_accessor :iDList

  def initialize(iDList = nil)
    @iDList = iDList
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetAssayDescription
#   aID - SOAP::SOAPInt
#   getVersion - SOAP::SOAPBoolean
#   getCounts - SOAP::SOAPBoolean
#   getFullDataBlob - SOAP::SOAPBoolean
#   eFormat - FormatType
class GetAssayDescription
  attr_accessor :aID
  attr_accessor :getVersion
  attr_accessor :getCounts
  attr_accessor :getFullDataBlob
  attr_accessor :eFormat

  def initialize(aID = nil, getVersion = nil, getCounts = nil, getFullDataBlob = nil, eFormat = nil)
    @aID = aID
    @getVersion = getVersion
    @getCounts = getCounts
    @getFullDataBlob = getFullDataBlob
    @eFormat = eFormat
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetAssayDescriptionResponse
#   assayDescription - AssayDescriptionType
#   dataBlob - DataBlobType
class GetAssayDescriptionResponse
  attr_accessor :assayDescription
  attr_accessor :dataBlob

  def initialize(assayDescription = nil, dataBlob = nil)
    @assayDescription = assayDescription
    @dataBlob = dataBlob
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetAssayColumnDescription
#   aID - SOAP::SOAPInt
#   heading - HeadingType
#   tID - SOAP::SOAPInt
class GetAssayColumnDescription
  attr_accessor :aID
  attr_accessor :heading
  attr_accessor :tID

  def initialize(aID = nil, heading = nil, tID = nil)
    @aID = aID
    @heading = heading
    @tID = tID
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetAssayColumnDescriptionResponse
#   columnDescription - ColumnDescriptionType
class GetAssayColumnDescriptionResponse
  attr_accessor :columnDescription

  def initialize(columnDescription = nil)
    @columnDescription = columnDescription
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetAssayColumnDescriptions
#   aID - SOAP::SOAPInt
class GetAssayColumnDescriptions
  attr_accessor :aID

  def initialize(aID = nil)
    @aID = aID
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}GetAssayColumnDescriptionsResponse
class GetAssayColumnDescriptionsResponse < ::Array
  include DRbUndumped
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputAssay
#   aID - SOAP::SOAPInt
#   columns - AssayColumnsType
#   listKeyTIDs - SOAP::SOAPString
#   listKeySCIDs - SOAP::SOAPString
#   outcomeFilter - AssayOutcomeFilterType
class InputAssay
  attr_accessor :aID
  attr_accessor :columns
  attr_accessor :listKeyTIDs
  attr_accessor :listKeySCIDs
  attr_accessor :outcomeFilter

  def initialize(aID = nil, columns = nil, listKeyTIDs = nil, listKeySCIDs = nil, outcomeFilter = nil)
    @aID = aID
    @columns = columns
    @listKeyTIDs = listKeyTIDs
    @listKeySCIDs = listKeySCIDs
    @outcomeFilter = outcomeFilter
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}InputAssayResponse
#   assayKey - SOAP::SOAPString
class InputAssayResponse
  attr_accessor :assayKey

  def initialize(assayKey = nil)
    @assayKey = assayKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}AssayDownload
#   assayKey - SOAP::SOAPString
#   assayFormat - AssayFormatType
#   eCompress - CompressType
class AssayDownload
  attr_accessor :assayKey
  attr_accessor :assayFormat
  attr_accessor :eCompress

  def initialize(assayKey = nil, assayFormat = nil, eCompress = nil)
    @assayKey = assayKey
    @assayFormat = assayFormat
    @eCompress = eCompress
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}AssayDownloadResponse
#   downloadKey - SOAP::SOAPString
class AssayDownloadResponse
  attr_accessor :downloadKey

  def initialize(downloadKey = nil)
    @downloadKey = downloadKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}ScoreMatrix
#   listKey - SOAP::SOAPString
#   secondaryListKey - SOAP::SOAPString
#   scoreType - ScoreTypeType
#   matrixFormat - MatrixFormatType
#   eCompress - CompressType
#   n3DConformers - SOAP::SOAPInt
#   no3DParent - SOAP::SOAPBoolean
class ScoreMatrix
  attr_accessor :listKey
  attr_accessor :secondaryListKey
  attr_accessor :scoreType
  attr_accessor :matrixFormat
  attr_accessor :eCompress
  attr_accessor :n3DConformers
  attr_accessor :no3DParent

  def initialize(listKey = nil, secondaryListKey = nil, scoreType = nil, matrixFormat = nil, eCompress = nil, n3DConformers = nil, no3DParent = nil)
    @listKey = listKey
    @secondaryListKey = secondaryListKey
    @scoreType = scoreType
    @matrixFormat = matrixFormat
    @eCompress = eCompress
    @n3DConformers = n3DConformers
    @no3DParent = no3DParent
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}ScoreMatrixResponse
#   downloadKey - SOAP::SOAPString
class ScoreMatrixResponse
  attr_accessor :downloadKey

  def initialize(downloadKey = nil)
    @downloadKey = downloadKey
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}IDExchange
#   inputListKey - SOAP::SOAPString
#   operation - IDOperationType
#   outputType - PCIDType
#   outputSourceName - SOAP::SOAPString
#   outputFormat - IDOutputFormatType
#   toWebEnv - SOAP::SOAPString
#   eCompress - CompressType
class IDExchange
  attr_accessor :inputListKey
  attr_accessor :operation
  attr_accessor :outputType
  attr_accessor :outputSourceName
  attr_accessor :outputFormat
  attr_accessor :toWebEnv
  attr_accessor :eCompress

  def initialize(inputListKey = nil, operation = nil, outputType = nil, outputSourceName = nil, outputFormat = nil, toWebEnv = nil, eCompress = nil)
    @inputListKey = inputListKey
    @operation = operation
    @outputType = outputType
    @outputSourceName = outputSourceName
    @outputFormat = outputFormat
    @toWebEnv = toWebEnv
    @eCompress = eCompress
  end
end

# {http://pubchem.ncbi.nlm.nih.gov/}IDExchangeResponse
#   listKey - SOAP::SOAPString
#   downloadKey - SOAP::SOAPString
class IDExchangeResponse
  attr_accessor :listKey
  attr_accessor :downloadKey

  def initialize(listKey = nil, downloadKey = nil)
    @listKey = listKey
    @downloadKey = downloadKey
  end
end
