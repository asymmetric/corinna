class FlickrController < ApplicationController

  require "flickraw"
  skip_before_filter :verify_authenticity_token, :ensure_application_is_installed_by_facebook_user, :get_current_facebook_user

  def index
    @server_id = params[:server]
    @hunt_id = params[:hunt]
    respond_to do |format|
      format.html
    end
  end

  def search
    @server_id = params[:server]
    @hunt_id = params[:hunt]
    query = params[:image]
    @photos = flickr.photos.search(:text => query, :per_page => '20', :sort => 'relevance' )
    respond_to do |format|
      format.html
    end
  end
end
