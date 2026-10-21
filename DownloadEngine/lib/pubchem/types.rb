require 'drb'

# PubChem data types used by DownloadEngine.
#
# The enum classes and their string values are the same as in the old PUG SOAP
# bindings (pubchem/service/default.rb), because the application stores and
# compares these values (e.g. queries.outcome_assay_filter). This file does not
# depend on soap4r.

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

# Assay description, filled from PUG REST assay "summary" and "description".
# Same attributes as the SOAP AssayDescriptionType. It stays DRbUndumped because
# DataBaseServer reads it through DRb from another process.
class AssayDescriptionType
  include DRbUndumped
  attr_accessor :name
  attr_accessor :description
  attr_accessor :protocol
  attr_accessor :comment
  attr_accessor :numberOfTIDs
  attr_accessor :hasScore
  attr_accessor :method
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

  def initialize(attributes = {})
    attributes.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  # `method` clashes with Object#method, so callers use assay_method.
  def assay_method
    @method
  end
end

class AssayTargetType
  include DRbUndumped
  attr_accessor :gi
  attr_accessor :name

  def initialize(gi = nil, name = nil)
    @gi = gi
    @name = name
  end
end

# Same attributes as the SOAP ColumnDescriptionType.
class ColumnDescriptionType
  include DRbUndumped
  attr_accessor :heading
  attr_accessor :tID
  attr_accessor :name
  attr_accessor :description
  attr_accessor :type
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

  # `type` is confusing next to the class type, so callers use column_type.
  def column_type
    @type
  end
end

class TestedConcentrationType
  include DRbUndumped
  attr_accessor :concentration
  attr_accessor :unit

  def initialize(concentration = nil, unit = nil)
    @concentration = concentration
    @unit = unit
  end
end

# Wrapper kept so callers can still write GetAssayDescription(...).assayDescription
class GetAssayDescriptionResponse
  include DRbUndumped
  attr_accessor :assayDescription

  def initialize(assayDescription = nil)
    @assayDescription = assayDescription
  end
end
