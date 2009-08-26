class ListController < ApplicationController
  ensure_application_is_installed_by_facebook_user
  before_filter :get_current_facebook_user
  def index
    @servers = Server.find(:all).collect do |server|
      TreasureHunt.site = server.url
      TreasureHunt.prefix = "#{TreasureHunt.site.path}/"
      { :server => server , :hunts => (TreasureHunt.find(:all) rescue []) }
    end
    @hunts_n = @servers.inject(0) { |total, server| total + server[:hunts].size } || 0
    respond_to do |format|
      format.fbml
    end
  end
  private
  def get_current_facebook_user
    @current_facebook_user = facebook_session.user
    unless @current_user = User.find(@current_facebook_user.to_s)
      @current_user = User.new
      @current_user.id = @current_facebook_user.to_s
      @current_user.password = ActiveSupport::SecureRandom.hex
      @current_user.servers = Server.find(:all).collect { |serv| { :id => serv.id, :thunts => [] } }
      @current_user.save
      @current_user = User.find(@current_facebook_user.to_s)
    end
  end
end
