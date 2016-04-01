class PrepareReceptor < ActiveRecord::Base
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
      self.receptor = PIAM::Application::DOCKING_MANAGER.upload_file(target.name, File.basename(@receptor_file.original_filename), @receptor_file.read)
    else
      errors.add(:uploaded_receptor, "is a required field, you must select a receptor file")
      return false;
    end
  end

end
