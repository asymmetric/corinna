class TreasureHuntsController < ApplicationController
  ensure_application_is_installed_by_facebook_user
  before_filter :get_current_facebook_user

  # GET /treasure_hunts
  def index
    @hunts = TreasureHunt.find(:all)

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  # GET /treasure_hunts/new
  def new
    @hunt = TreasureHunt.new(:xml => "")

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  # POST /treasure_hunts
  def create
    hunt_pwd = ActiveSupport::SecureRandom.base64 20
    xml = REXML::Document.new(params[:treasure_hunt]['xml'])
    if xml.root and xml.root.attributes and xml.root.attributes['idOrganizer'] and xml.root.attributes['pwdOrganizer']
      xml.root.attributes['idOrganizer'] = @current_facebook_user.to_s
      xml.root.attributes['pwdOrganizer'] = hunt_pwd
    end

    @hunt = TreasureHunt.new(:xml => xml.to_s)

    respond_to do |format|
      begin
        @hunt.save
        @current_user.thunts << { :id => @hunt.id, :password => hunt_pwd }
        @current_user.save
        flash[:notice] = 'Treasure Hunt was successfully created.'
        format.html { redirect_to(@hunt) }
        format.fbml { redirect_to(@hunt) }
      rescue
        format.html { render :action => "new" }
        format.fbml { render :action => "new" }
      end
    end

  end

  # GET /treasure_hunts/1
  def show
    @hunt = TreasureHunt.find(params[:id])

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  # TODO: VERB? /treasure_hunts/1/subscribe
  def subscribe
    @hunt = TreasureHunt.find(params[:id])

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  # DELETE /treasure_hunts/1
  def destroy
    @hunt = TreasureHunt.find(params[:id])
    @hunt.destroy(@current_user.id, @current_user.hunt_password(@hunt.id))
    @current_user.thunts.delete_if { |x| x.has_key? @hunt.id }
    @current_user.save
    flash[:notice] = "Treasure Hunt successfully destroyed"

    respond_to do |format|
      format.html { redirect_to(treasure_hunts_url) }
      format.fbml { redirect_to(treasure_hunts_url) }
    end
  end

  private
  def get_current_facebook_user
    @current_facebook_user = facebook_session.user
    @current_user = User.find(@current_facebook_user.to_s)
    unless @current_user
      @current_user = User.new
      @current_user.id = @current_facebook_user.to_s
      @current_user.password = ActiveSupport::SecureRandom.base64 20
      @current_user.thunts = []
      @current_user.save
    end
  end
end
