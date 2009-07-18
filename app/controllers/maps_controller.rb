class MapsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def index
    @content = "
      function initialize() {
        var myLatlng = new google.maps.LatLng(#{params[:lat]}, #{params[:lng]});
        var myOptions = {
          zoom: #{params[:z]},
          center: myLatlng,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        }
        var map = new google.maps.Map(document.getElementById(\"map_canvas\"), myOptions);
        var marker = new google.maps.Marker({
          position: myLatlng,
          map: map,
          title: \"Hello World!\"
        });
      }"

    respond_to do |format|
      format.html
    end
  end
end
