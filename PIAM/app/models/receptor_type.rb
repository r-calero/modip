class ReceptorType < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :name
  has_many :prepare_receptors

  before_validation :strip_name

  # The name is a label an administrator chooses. It ends up in result file
  # names (sanitised by the docking server), in CSV headers and on the page,
  # so punctuation is allowed: the limits are the width of the column, which
  # MySQL would otherwise truncate without saying so, and characters that are
  # never part of a label.
  validates :name, :presence => true, :uniqueness => true,
                   :length => { :maximum => 45 },
                   :format => { :with => /\A[^[:cntrl:]]+\z/, :message => 'may not contain control characters' }

  def is_bovine
  	name == "Bovine Receptor"
  end

  def is_human
  	name == "Human Receptor"
  end

  def is_parasite
    name == "Parasite Receptor"
  end

  private

  def strip_name
    self.name = name.strip if name.respond_to?(:strip)
  end
end
