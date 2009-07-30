class ListController < ApplicationController
  ensure_application_is_installed_by_facebook_user
  def index
    @servers = Server.find(:all).collect do |server|
      TreasureHunt.site = server.url
      TreasureHunt.prefix = "#{TreasureHunt.site.path}/"
      { :server => server , :hunts => (TreasureHunt.find(:all) rescue []) }
    end
    respond_to do |format|
      format.fbml
      format.html
    end
  end
end
