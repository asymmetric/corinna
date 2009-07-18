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
      rescue ActiveTreasureHunt::XMLError => e
        flash[:error] = "Error: #{e.to_s}"
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

  # POST /treasure_hunts/1/subscribe
  def subscribe
    @hunt = TreasureHunt.find(params[:id])
    begin
      case params[:button]
      when "user"
        @hunt.subscribe :user, @current_user.id, @current_user.password
        flash[:notice] = "Successfully subscribed to Treasure Hunt #{@hunt.id}"
      when "group"
        group_id = params[:gid].to_i
        group_name = @current_facebook_user.groups.find { |g| g.gid == group_id }.name
        @hunt.subscribe :group, @current_user.id, @current_user.password
        #@hunt.subscribe :group, group_id, @current_user.password
        flash[:notice] = "Successfully subscribed as group #{group_name}"
      end
    rescue ActiveTreasureHunt::XMLError => e
      flash[:error] = "Subscription failed: #{e.to_s}"
    end

    respond_to do |format|
      format.html { redirect_to(@hunt) }
      format.fbml { redirect_to(@hunt) }
    end
  end

  def hint
    @hunt = TreasureHunt.find params[:id]

    respond_to do |format|
      begin
        @hint = @hunt.gethint @current_user.id, @current_user.password
        format.html
        format.fbml
      rescue ActiveTreasureHunt::XMLError => e
        flash[:notice] = "Error: #{e.to_s}"
        format.html { redirect_to(@hunt) }
        format.fbml { redirect_to(@hunt) }
      end
    end
  end

  def start
    @hunt = TreasureHunt.find params[:id]

    begin
      hunt_pwd = self.get_admin_password @hunt.id
      @hint = @hunt.start @current_user.id, hunt_pwd
      flash[:notice] = "Treasure Hunt successfully started"
    rescue ActiveTreasureHunt::XMLError => e
      flash[:error] = "Error: #{e.to_s}"
    end

    respond_to do |format|
      format.html { redirect_to @hunt }
      format.fbml { redirect_to @hunt }
    end
  end

  def answer
    @hunt = TreasureHunt.find params[:id]
  end

  # DELETE /treasure_hunts/1
  def destroy
    @hunt = TreasureHunt.find(params[:id])
    begin
      @hunt.destroy(@current_user.id, @current_user.hunt_password(@hunt.id))
      @current_user.thunts.delete_if { |x| x.id == @hunt.id }
      @current_user.save
      flash[:notice] = "Treasure Hunt successfully destroyed"
    rescue ActiveTreasureHunt::XMLError => e
      flash[:error] = "Error: #{e.to_s}"
    end

    respond_to do |format|
      format.html { redirect_to(treasure_hunts_url) }
      format.fbml { redirect_to(treasure_hunts_url) }
    end
  end

  protected
  def get_admin_password(hunt_id)
    @current_user.thunts.find { |h| h.id == hunt_id }.password
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

