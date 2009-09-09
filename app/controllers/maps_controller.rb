class MapsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :ensure_application_is_installed_by_facebook_user, :get_current_facebook_user
  def index
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true, :map_type => true)
    @map.set_map_type_init(GMapType::G_HYBRID_MAP)
    @map.center_zoom_init([lat,lng],params[:z].to_i)
    address = Geokit::Geocoders::GoogleGeocoder.do_reverse_geocode(Geokit::LatLng.new(lat,lng))
    full_address = address.full_address if address.respond_to? :full_address
    @map.overlay_init(GMarker.new([lat,lng],
                                  :title => full_address,
                                  :info_window => "<div class=\"gmls-result-wrapper\"><p>#{full_address}</p></div>"
                                  ))
    respond_to do |format|
      format.html
    end
  end

  def search
    @server_id = params[:server]
    @hunt_id = params[:hunt]
    @map = GMap.new("map")
    @map.control_init(:large_map => true, :map_type => true, :local_search => true, :anchor => :bottom_left, :offset_width => 0, :offset_height => -30, :local_search_options => "{resultList : document.getElementById('results'), onGenerateMarkerHtmlCallback : extendMarker}")
    @map.set_map_type_init(GMapType::G_HYBRID_MAP)
    @map.center_zoom_init([44.501824,11.340463],11)
    form = "<p><em>If you think this is the correct solution...</em><form action='http://apps.facebook.com#{Facebooker.facebook_path_prefix}/servers/#{@server_id}/treasure_hunts/#{@hunt_id}/answer?type=geoloc' method='post' target='_top'><input type='hidden' name='geoloc_lat' value='\"+ latlng.lat() +\"' /><input type='hidden' name='geoloc_long' value='\"+ latlng.lng() +\"' /><input type='submit' value='Submit it!' /></form>";
    @map.record_init("function extendMarker(marker, html, result) {
      // remove directions to .. from ..
      gsdir = html.getElementsByClassName('gs-directions-to-from')[0];
      html.removeChild(gsdir);
      // get latlng
      latlng = marker.getLatLng();
      // create form
      div = document.createElement('div');
      div.innerHTML = \"#{form}\";
      html.appendChild(div);
      return html;}")
    @map.event_init(@map, :click, "function(overlay, latlng) {
    var myHtml = '<div class=\"gmls-result-wrapper\">Latitude: ' + latlng.lat() + '<br />Longitude: ' + latlng.lng() + \"#{form}</div>\";
    map.openInfoWindow(latlng, myHtml); }")

    respond_to do |format|
      format.html
    end
  end
end
