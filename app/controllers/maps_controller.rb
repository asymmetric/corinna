class MapsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :ensure_application_is_installed_by_facebook_user, :get_current_facebook_user
  def index
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.set_map_type_init(GMapType::G_HYBRID_MAP)
    @map.center_zoom_init([lat,lng],params[:z].to_i)
    address = Geokit::Geocoders::GoogleGeocoder.do_reverse_geocode(Geokit::LatLng.new(lat,lng))
    full_address = address.full_address if address.respond_to? :full_address
    @map.overlay_init(GMarker.new([lat,lng],
                                  :title => full_address,
                                  :info_window => "<h3>Address:</h3>#{full_address}"
                                  ))
    respond_to do |format|
      format.html
    end
  end

  def search
    @server_id = params[:server]
    @hunt_id = params[:hunt]
    respond_to do |format|
      format.html
    end
  end
end
