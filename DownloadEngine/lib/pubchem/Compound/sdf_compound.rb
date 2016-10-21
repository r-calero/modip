require 'pubchem/Compound/compound'
require 'pubchem/SDF/SDFParser'
require 'date'

class SDFCompound < CompoundFile
  @@element_filter = ['Na']

  @@compound_cid = 'PUBCHEM_COMPOUND_CID'
  @@compound_coordinate_id_type = 'PUBCHEM_COMPOUND_ID_TYPE'
  @@heavy_atom_count = 'PUBCHEM_HEAVY_ATOM_COUNT'
  @@atom_def_stereo_count = 'PUBCHEM_ATOM_DEF_STEREO_COUNT'
  @@atom_udef_stereo_count = 'PUBCHEM_ATOM_UDEF_STEREO_COUNT'
  @@bond_def_stereo_count = 'PUBCHEM_BOND_DEF_STEREO_COUNT'
  @@bond_udef_stereo_count = 'PUBCHEM_BOND_UDEF_STEREO_COUNT'
  @@isotopic_atom_count =	'PUBCHEM_ISOTOPIC_ATOM_COUNT'
  @@component_count = 'PUBCHEM_COMPONENT_COUNT'
  @@cactvs_tauto_count = 'PUBCHEM_CACTVS_TAUTO_COUNT'
  @@coordinate_type =	'PUBCHEM_COORDINATE_TYPE'
  @@date = ''
  @@molecular_formula = 'PUBCHEM_MOLECULAR_FORMULA'
  @@molecular_weight = 'PUBCHEM_MOLECULAR_WEIGHT'
  @@monoisotopic_weight = 'PUBCHEM_MONOISOTOPIC_WEIGHT'
  @@exact_mass = 'PUBCHEM_EXACT_MASS'
  @@nonstandardbond = 'PUBCHEM_NONSTANDARDBOND'
  @@bondannotations = 'PUBCHEM_BONDANNOTATIONS'
  @@compound_canonicalized = 'PUBCHEM_COMPOUND_CANONICALIZED'
  @@total_charge = 'PUBCHEM_TOTAL_CHARGE'
  @@cactvs_hbond_acceptor = 'PUBCHEM_CACTVS_HBOND_ACCEPTOR'
  @@cactvs_hbond_donor = 'PUBCHEM_CACTVS_HBOND_DONOR'
  @@cactvs_rotatable_bond = 'PUBCHEM_CACTVS_ROTATABLE_BOND'
  @@cactvs_complexity = 'PUBCHEM_CACTVS_COMPLEXITY'
  @@cactvs_subskeys = 'PUBCHEM_CACTVS_SUBSKEYS'
  @@cactvs_tpsa = 'PUBCHEM_CACTVS_TPSA'
  @@xlogp3 = 'PUBCHEM_XLOGP3'
  @@xlogp3_aa = 'PUBCHEM_XLOGP3_AA'
  @@iupac_inchi = 'PUBCHEM_IUPAC_INCHI'
  @@iupac_inchikey = 'PUBCHEM_IUPAC_INCHIKEY'
  @@openeye_can_smiles = 'PUBCHEM_OPENEYE_CAN_SMILES'
  @@openeye_iso_smiles = 'PUBCHEM_OPENEYE_ISO_SMILES'
  @@iupac_name = 'PUBCHEM_IUPAC_NAME'
  @@iupac_traditional_name = 'PUBCHEM_IUPAC_TRADITIONAL_NAME'
  @@iupac_systematic_name = 'PUBCHEM_IUPAC_SYSTEMATIC_NAME'
  @@openeye_tauto_count = 'PUBCHEM_OPENEYE_TAUTO_COUNT'
  #-------------3d---------------------------------------
  @@conformer_id_list = 'PUBCHEM_CONFORMER_ID_LIST'
  @@conformer_diverseorder = 'PUBCHEM_CONFORMER_DIVERSEORDER'
  @@pharmacophore_features = 'PUBCHEM_PHARMACOPHORE_FEATURES'
  @@effective_rotor_count = 'PUBCHEM_EFFECTIVE_ROTOR_COUNT'
  @@mmff94_partial_charges = 'PUBCHEM_MMFF94_PARTIAL_CHARGES'
  @@conformer_rmsd = 'PUBCHEM_CONFORMER_RMSD'
  @@conformer_id = 'PUBCHEM_CONFORMER_ID'
  @@shape_volume = 'PUBCHEM_SHAPE_VOLUME'
  @@mmff94_energy = 'PUBCHEM_MMFF94_ENERGY'
  @@shape_multipoles = 'PUBCHEM_SHAPE_MULTIPOLES'
  @@shape_fingerprint = 'PUBCHEM_SHAPE_FINGERPRINT'
  @@shape_selfoverlap = 'PUBCHEM_SHAPE_SELFOVERLAP'
  @@feature_selfoverlap = 'PUBCHEM_FEATURE_SELFOVERLAP'


  def initialize(dir, name)
    super(dir, name)
    @sdf = SDFParser.parser(dir)[0]
    @array_struct = @sdf.struct.scan(/.+$/)
    @atom_number = @array_struct[2].scan(/\d+/)[0].to_i
    arr = try_get_expr(@@coordinate_type)
    if arr.length == 3
      @coordinate = arr[0].to_i
      @coordinate_source_id = arr[1].to_i
      @coordinate_unit_id = arr[2].to_i
    end
  end

  def filename
    @filename
  end

  def cid
    @sdf[@@compound_cid].gsub(/\s+$/,'') if @sdf[@@compound_cid]
  end

  def path
    @path
  end

  def coordinate
    @coordinate
  end

  def coordinate_source_id
    @coordinate_source_id
  end

  def coordinate_unit_id
    @coordinate_unit_id
  end

  def molecular_weight
    try_get_type(@@molecular_weight, 'float')
  end

  def molecular_formula
    @sdf[@@molecular_formula].gsub(/\s+$/,'') if @sdf[@@molecular_formula]
  end

  def name
    @sdf[@@iupac_name].gsub(/\s+$/,'') if @sdf[@@iupac_name]
  end

  def xlogp3
    xlogp3 = try_get_type(@@xlogp3, 'float')
    xlogp3 = try_get_type(@@xlogp3_aa, 'float') unless xlogp3
  end

  def cactvs_hbond_donor
    try_get_type(@@cactvs_hbond_donor)
  end

  def cactvs_hbond_acceptor
    try_get_type(@@cactvs_hbond_acceptor)
  end

  def cactvs_rotatable_bond
    try_get_type(@@cactvs_rotatable_bond)
  end

  def openeye_iso_smiles
    @sdf[@@openeye_iso_smiles].gsub(/\s+$/,'') if @sdf[@@openeye_iso_smiles]
  end

  def cactvs_tpsa
    try_get_type(@@cactvs_tpsa, 'float')
  end

  def heavy_atom_count
    try_get_type(@@heavy_atom_count)
  end

  def component_count
    try_get_type(@@component_count)
  end

  def cactvs_tauto_count
    try_get_type(@@cactvs_tauto_count)
  end

  def atom_number
    @atom_number
  end

  def iupac_traditional_name
    @sdf[@@iupac_traditional_name].gsub(/\s+$/,'') if @sdf[@@iupac_traditional_name]
  end

  def inchi
    @sdf[@@iupac_inchi].gsub(/\s+$/,'') if @sdf[@@iupac_inchi]
  end

  def is_3d
    return @coordinate == 2
  end

  def date
    Time.now.strftime("%Y-%m-%d")
  end

  def struct
    @sdf.struct
  end

  def copy_missing_data(other)
    @sdf[@@iupac_name] = other.inner_data[@@iupac_name] if other.name
    @sdf[@@molecular_formula] = other.inner_data[@@molecular_formula] if other.molecular_formula
    @sdf[@@iupac_traditional_name] = other.inner_data[@@iupac_traditional_name] if other.iupac_traditional_name
    @sdf[@@molecular_weight] = other.inner_data[@@molecular_weight] if other.molecular_weight
    @sdf[@@iupac_inchi] = other.inner_data[@@iupac_inchi] if other.inchi
    @sdf[@@cactvs_hbond_acceptor] = other.inner_data[@@cactvs_hbond_acceptor] if other.cactvs_hbond_acceptor
    @sdf[@@cactvs_hbond_donor] = other.inner_data[@@cactvs_hbond_donor] if other.cactvs_hbond_donor
    @sdf[@@openeye_iso_smiles] = other.inner_data[@@openeye_iso_smiles] if other.openeye_iso_smiles
    @sdf[@@cactvs_tpsa] = other.inner_data[@@cactvs_tpsa] if other.cactvs_tps
    @sdf[@@cactvs_rotatable_bond] = other.inner_data[@@cactvs_rotatable_bond] if other.cactvs_rotatable_bond

    if other.xlogp3
      xlogp3 = other.inner_data[@@xlogp3]
      xlogp3 = other.inner_data[@@xlogp3_aa] unless xlogp3
      @sdf[@@xlogp3] = xlogp3
    end
  end

  def struct= (other)
    @sdf.struct = other
  end

  def set_coordinate(other)
    if other.coordinate and other.coordinate_source_id and other.coordinate_unit_id
      @coordinate = other.coordinate
      @coordinate_source_id = other.coordinate_source_id
      @coordinate_unit_id = other.coordinate_unit_id
      @sdf[@@coordinate_type] = other.inner_data[@@coordinate_type]
    end
  end

  def inner_data
    @sdf
  end

  def to_s
    @sdf.to_s
  end

  private
  def try_get_type(key, type = 'int')
    value = @sdf[key]
    if value
      value = value.gsub(/\s+$/,'')
      case(type)
        when 'int'
          return value.to_i
        when 'float'
          return value.to_f
      end
    end
  end

  def try_get_expr(key, expr = /[\d|.]+/)
    value = @sdf[key]
    if value
      value = value.gsub(/\s+$/,'')
      return value.scan(expr)
    end
  end

end