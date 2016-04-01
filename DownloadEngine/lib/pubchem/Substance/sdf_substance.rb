require 'pubchem/Substance/substance'
require 'pubchem/SDF/SDFParser'

class SDFSubstance < Substance

	@@substance_id = "PUBCHEM_SUBSTANCE_ID"
	@@substance_version = "PUBCHEM_SUBSTANCE_VERSION"
	@@ext_datasource_name = "PUBCHEM_EXT_DATASOURCE_NAME"
	@@ext_datasource_regid = "PUBCHEM_EXT_DATASOURCE_REGID"
	@@ext_datasource_url = "PUBCHEM_EXT_DATASOURCE_URL"
	@@ext_substance_url = "PUBCHEM_EXT_SUBSTANCE_URL"
	@@substance_synonym = "PUBCHEM_SUBSTANCE_SYNONYM"
	@@substance_comment = "PUBCHEM_SUBSTANCE_COMMENT"
	@@depositor_record_date = "PUBCHEM_DEPOSITOR_RECORD_DATE"
	@@xref_ext_id = "PUBCHEM_XREF_EXT_ID"
	@@xref_substance_id = "PUBCHEM_XREF_SUBSTANCE_ID"
	@@xref_compound_id = "PUBCHEM_XREF_COMPOUND_ID"
	@@xref_assay_id = "PUBCHEM_XREF_ASSAY_ID"
	@@pubmed_id = "PUBCHEM_PUBMED_ID"
	@@genbank_nucleotide_id = "PUBCHEM_GENBANK_NUCLEOTIDE_ID"
	@@genbank_protein_id = "PUBCHEM_GENBANK_PROTEIN_ID"
	@@ncbi_taxonomy_id = "PUBCHEM_NCBI_TAXONOMY_ID"
	@@ncbi_omim_id = "PUBCHEM_NCBI_OMIM_ID"
	@@ncbi_mmdb_id = "PUBCHEM_NCBI_MMDB_ID"
	@@pubmed_mesh_term = "PUBCHEM_PUBMED_MESH_TERM"
	@@ncbi_gene_id = "PUBCHEM_NCBI_GENE_ID"
	@@ncbi_probe_id = "PUBCHEM_NCBI_PROBE_ID"
	@@ncbi_biosystem_id = "PUBCHEM_NCBI_BIOSYSTEM_ID"
	@@ncbi_geo_gse_id = "PUBCHEM_NCBI_GEO_GSE_ID"
	@@ncbi_geo_gsm_id = "PUBCHEM_NCBI_GEO_GSM_ID"
	@@mmdb_moecule_name = "PUBCHEM_MMDB_MOLECULE_NAME"
	@@mm_residue_id = "PUBCHEM_MMDB_RESIDUE_ID"
	@@mmdb_residue_name = "PUBCHEM_MMDB_RESIDUE_NAME"
	@@mmdb_atom_id = "PUBCHEM_MMDB_ATOM_ID"
	@@mmdb_atom_name = "PUBCHEM_MMDB_ATOM_NAME"
	@@hold_until_date = "PUBCHEM_HOLD_UNTIL_DATE"
	@@subs_auto_structure = "PUBCHEM_SUBS_AUTO_STRUCTURE"
	@@revoke_substance = "PUBCHEM_REVOKE_SUBSTANCE"
	@@cid_associations = "PUBCHEM_CID_ASSOCIATIONS"
	@@generic_registry_name = "PUBCHEM_GENERIC_REGISTRY_NAME"
	
	def initialize(dir)
		super(dir)
		@sdf = SDFParser.parser(dir)[0]		 
	end
	
	def cid
		result = []
		cids = @sdf.tag_value(@@cid_associations)
		if cids
			cids.scan(/.+$/).each do |line|
				result << line.scan(/\d+/)[0]
			end
		end
		return result
	end
end
