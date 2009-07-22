class AdminController < ApplicationController
  def index
    if request.get?
      @servers = Server.find("servers").servers.collect { |serv| serv.name }
      respond_to do |format|
        format.fbml
      end
    elsif request.post?
      servers = Server.find("servers")
      servers.current = params[:server].to_s
      servers.save
      flash[:notice] = "Successfully changed server to #{servers.current}"
      respond_to do |format|
        format.fbml { redirect_to treasure_hunts_url }
      end
    end
  end
end
