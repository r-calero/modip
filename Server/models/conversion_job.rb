# 2D -> 3D conversion of a compound (see PIAM/app/models/conversion_job.rb).
class ConversionJob < ActiveRecord::Base
  PENDING = %w(queued running)
  belongs_to :compound
end
