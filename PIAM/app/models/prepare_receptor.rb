class PrepareReceptor < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :target_id, :receptor_type_id, :uploaded_receptor, :comment, :center_x, :center_y, :center_z,
                  :size_x, :size_y, :size_z, :cpu_number, :energy_range, :number_of_conformer
  belongs_to :target
  belongs_to :receptor_type
  has_many :receptor_compounds
  
  validates :receptor, :format => {:with => %r{\.(pdbqt)$}i, :message => 'must be a path from .pdbqt file.'}, :on => :save
  validates :energy_range, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}
  validates_numericality_of  :center_x, :center_y, :center_z, :size_x, :size_y, :size_z 

  before_create :set_receptor_file
  before_update :set_receptor_file

  def uploaded_receptor=(receptor_field)
    @receptor_file = receptor_field
  end

  def set_receptor_file
    if(@receptor_file)
      filename = File.basename(@receptor_file.original_filename.to_s)
      unless filename =~ /\.(pdbqt|pdb)\z/i
        errors.add(:uploaded_receptor, "must be a .pdbqt file, or a .pdb file to be prepared with AutoDockTools")
        return false
      end
      path = PIAM::Application::DOCKING_MANAGER.upload_file(target.name, filename, @receptor_file.read)
      # A PDB is converted to PDBQT on the docking server (polar hydrogens added).
      path = PIAM::Application::DOCKING_MANAGER.prepare_receptor_file(path) if filename =~ /\.pdb\z/i
      self.receptor = path
    else
      errors.add(:uploaded_receptor, "is a required field, you must select a receptor file")
      return false;
    end
  end

end
