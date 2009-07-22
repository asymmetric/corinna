class MapsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def index
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([params[:lat].to_f,params[:lng].to_f],params[:z].to_i)
    @map.overlay_init(GMarker.new([params[:lat].to_f,params[:lng].to_f],:title => "What are you staring at?", :info_window => "Hi! :-)"))
    respond_to do |format|
      format.html
    end
  end
end
