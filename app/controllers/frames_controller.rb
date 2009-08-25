class FramesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :get_server

  def hint
    @hint = @hunt.gethint @current_user.id, @current_user.password
    respond_to do |format|
      format.fbjs
    end
  end

  def status
    resp = @hunt.status @current_user.id, @current_user.password
    xml = Nokogiri::XML resp
    @status = xml.root.xpath 'thunt:status'
    respond_to do |format|
      format.fbjs
    end
  end

  private
  def get_server
    @server = Server.find(params[:server_id])
    TreasureHunt.site = @server.url
    TreasureHunt.prefix = "#{TreasureHunt.site.path}/"
    @hunt ||= TreasureHunt.find params[:id]
  end
end
