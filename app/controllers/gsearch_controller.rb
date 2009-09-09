class GsearchController < ApplicationController
  skip_before_filter :ensure_application_is_installed_by_facebook_user, :get_current_facebook_user
  before_filter :get_params

  def videos
    @type = 'video'
    @searchers = 'searchControl.addSearcher(new google.search.VideoSearch(),options);'

    respond_to do |format|
      format.html
    end
  end

  def web
    @type = 'URI'
    @searchers = 'searchControl.addSearcher(new google.search.WebSearch(),options);'

    respond_to do |format|
      format.html
    end
  end

  private
  def get_params
    @server_id = params[:server_id]
    @hunt_id = params[:hunt_id]
  end
end
