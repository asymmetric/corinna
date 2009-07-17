class MapsController < ApplicationController
  #skip_before_filter :verify_authenticity_token
  def index
    @content = "
      function initialize() {
        var latlng = new google.maps.LatLng(#{params[:lat]}, #{params[:lng]});
        var myOptions = {
          zoom: #{params[:z]},
          center: latlng,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var contentString = 'Qui ci dovrebbe stare qualcosa';
        var infowindow = new google.maps.InfoWindow({
          content: contentString
        });
        var map = new google.maps.Map(document.getElementById(\"map_canvas\"), myOptions);
        var marker = new google.maps.Marker({
          position: latlng,
          map: map,
          title:\"Hello World!\"
        });
        google.maps.event.addListener(marker, 'click', function() {
          infowindow.open(map,marker);
        });
      }"

    respond_to do |format|
      format.html
    end
  end
end
