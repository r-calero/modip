# 3D viewer of docking poses (3Dmol.js). Results are public, like the ranking;
# only files recorded in receptor_compounds can be opened.
class PosesController < ApplicationController
  skip_before_filter :authorize

  # GET /poses?path=data/Targets/.../pose.pdbqt
  def show
    @pose = find_pose
    @receptor = @pose.prepare_receptor
    @compound = @pose.compound
    @models = ReceptorCompound.where(:path => @pose.path).order(:id).pluck(:value)
  end

  # GET /poses/data?path=...  (receptor and pose files, as text, for the viewer)
  def data
    pose = find_pose
    receptor = pose.prepare_receptor
    render :json => {
      :receptor => PIAM::Application::DOCKING_MANAGER.get_resource(receptor.receptor).join,
      :pose => PIAM::Application::DOCKING_MANAGER.get_resource(pose.path).join
    }
  end

  private

  def find_pose
    pose = ReceptorCompound.where(:path => params[:path].to_s).includes(:compound, :prepare_receptor => [:receptor_type, :target]).first
    raise ActiveRecord::RecordNotFound, "Docking pose not found" unless pose
    pose
  end
end
