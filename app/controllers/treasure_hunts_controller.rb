class TreasureHuntsController < ApplicationController
  begin
    request_comes_from_facebook?
    ensure_application_is_installed_by_facebook_user
    before_filter :get_current_facebook_user
  rescue NoMethodError => e
    # This is THE ONLY WAY to get the app working both IN facebook and OUT of facebook DON'T TOUCH OR I'LL KILL YOU!
  end

  # load - id, pwd, config
  # subscribe - id, pwd, hunt
  # remove - id, pwd, hunt
  # start - id, pwd, hunt

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
    @hunt = TreasureHunt.new
    @hunt.xml = ""

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  # POST /treasure_hunts
  def create
    @hunt = TreasureHunt.new(params[:treasure_hunt])
    respond_to do |format|
      if @hunt.save
        flash[:notice] = 'Treasure Hunt was successfully created.'
        format.html { redirect_to(@hunt) }
        format.fbml { redirect_to(@hunt) }
      else
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

  # GET /treasure_hunts/subscribe/1
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
    @hunt.destroy
    redirect_to(treasure_hunts_url)

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  private
  def get_current_facebook_user
    @current_facebook_user = facebook_session.user
    @current_user = User.find(@current_facebook_user.to_i)
  end
end
