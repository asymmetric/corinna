class VideosController < ApplicationController
  skip_before_filter :ensure_application_is_installed_by_facebook_user, :get_current_facebook_user
   
 def index
  @server_id = params[:server_id]
  @hunt_id = params[:hunt_id]
  debugger
  respond_to do |format|
  format.html
  end
 end

end
