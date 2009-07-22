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
    hunt_pwd = ActiveSupport::SecureRandom.hex
    xml = Nokogiri::XML(params[:treasure_hunt]['xml'])
    if xml.root and xml.root['idOrganizer'] and xml.root['pwdOrganizer']
      xml.root['idOrganizer'] = @current_facebook_user.to_s
      xml.root['pwdOrganizer'] = hunt_pwd
      xml.encoding = 'UTF-8'
    end

    @hunt = TreasureHunt.new(:xml => xml.to_xml.gsub(/;/,''))

    respond_to do |format|
      begin
        @hunt.save
        @current_user.thunts << { :id => @hunt.id, :password => hunt_pwd }
        @current_user.save
        flash[:notice] = 'Treasure Hunt successfully created!'
        format.html { redirect_to(@hunt) }
        format.fbml { redirect_to(@hunt) }
      rescue ActiveTreasureHunt::XMLError => e
        flash[:error] = e.message
        @hunt.xml = ""
        format.html { render :action => "new" }
        format.fbml { render :action => "new" }
      end
    end

  end

  # GET /treasure_hunts/1
  def show
    respond_to do |format|
      begin
        @hunt = TreasureHunt.find(params[:id])
        format.html
        format.fbml
      rescue ActiveTreasureHunt::XMLError => e
        flash[:error] = e.message
        format.html { redirect_to treasure_hunts_url }
        format.fbml { redirect_to treasure_hunts_url }
      end
    end
  end

  def fakehint

    respond_to do |format|
      if request.get?
        @hunt = TreasureHunt.find params[:id]

        format.html
        format.fbml
       elsif request.post?
         begin
           @hunt = TreasureHunt.find params[:id]
           @turn = params[:turn]
           @fake_hint = params[:fakehint]

           @hunt.fakehint @fake_hint, @turn, @current_user.id, @current_user.password
           flash[:notice] = "Fake hint successfully sent!"
           format.html { redirect_to @hunt }
           format.fbml { redirect_to @hunt }
         rescue ActiveTreasureHunt::XMLError => e
           flash[:error] = e.message
           format.html
           format.fbml
         end
       end
    end
  end

  # POST /treasure_hunts/1/subscribe
  def subscribe
    @hunt = TreasureHunt.find(params[:id])
    begin
      case params[:button]
      when "user"
        @hunt.subscribe :user, @current_user.id, @current_user.password
        flash[:notice] = "Successfully subscribed!"
      when "group"
        group_id = params[:gid].to_i
        group_name = @current_facebook_user.groups.find { |g| g.gid == group_id }.name
        @hunt.subscribe :group, @current_user.id, @current_user.password
        #@hunt.subscribe :group, group_id, @current_user.password
        flash[:notice] = "Successfully subscribed as group #{group_name}!"
      end
    rescue ActiveTreasureHunt::XMLError => e
      #flash[:error] = e.message
    end

    respond_to do |format|
      format.html { redirect_to :action => :hint }
      format.fbml { redirect_to :action => :hint }
    end
  end

  def hint
    @hunt = TreasureHunt.find params[:id]

    respond_to do |format|
      begin
        @hint = @hunt.gethint @current_user.id, @current_user.password
        begin
          resp = @hunt.status @current_user.id, @current_user.password
          xml = Nokogiri::XML resp
          @status = xml.root.xpath 'thunt:status'
        rescue ActiveTreasureHunt::XMLError => e
          @nostatus = e.message
        end
        format.html
        format.fbml
      rescue ActiveTreasureHunt::XMLError => e
        flash[:error] = e.message
        format.html { redirect_to(@hunt) }
        format.fbml { redirect_to(@hunt) }
      end
    end
  end

  def status
    hunt = TreasureHunt.find params[:id]

    respond_to do |format|
      begin
        resp = hunt.status @current_user.id, @current_user.password
        xml = Nokogiri::XML resp
        @status = xml.root.xpath 'thunt:status'
        format.html
        format.fbml
      rescue ActiveTreasureHunt::XMLError => e
        flash[:error] = e.message
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
      flash[:notice] = "Treasure Hunt successfully started!"
    rescue ActiveTreasureHunt::XMLError => e
      flash[:error] = e.message
    end

    respond_to do |format|
      format.html { redirect_to @hunt }
      format.fbml { redirect_to @hunt }
    end
  end

  def answer

    # shows form to input the answer
    if request.get?
      @hunt = TreasureHunt.find params[:id]


      respond_to do |format|
        format.html
        format.fbml
      end
      # shows response from the server

    elsif request.post?
      @hunt = TreasureHunt.find params[:id]
      @answer_type = params[:answer_type]
      if @answer_type == :geoloc
        @answer = {}
        @answer[:lat] = params[:geoloc_lat]
        @answer[:long] = params[:geoloc_long]
        @answer[:planet] = params[:geoloc_planet]
      else
        @answer = params[:answer]
      end

      begin
        @resp = @hunt.answer @answer, @answer_type, @current_user.id, @current_user.password
        flash[:notice] = @resp
      rescue ActiveTreasureHunt::XMLError => e
        flash[:error] = e.message
      end


      respond_to do |format|
        format.html { redirect_to :action => :hint }
        format.fbml { redirect_to :action => :hint }
      end
    end
  end

  # DELETE /treasure_hunts/1
  def destroy
    @hunt = TreasureHunt.find(params[:id])
    begin
      @hunt.destroy(@current_user.id, @current_user.hunt_password(@hunt.id))
      @current_user.thunts.delete_if { |x| x.id == @hunt.id }
      @current_user.save
      flash[:notice] = "Treasure Hunt successfully destroyed!"
    rescue ActiveTreasureHunt::XMLError => e
      flash[:error] = e.message
    end

    respond_to do |format|
      format.html { redirect_to(treasure_hunts_url) }
      format.fbml { redirect_to(treasure_hunts_url) }
    end
  end

  def invite
    @hunt = TreasureHunt.find params[:id]

    respond_to do |format|
      format.html
      format.fbml
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
      @current_user.password = ActiveSupport::SecureRandom.hex
      @current_user.thunts = []
      @current_user.save
    end
  end
end
