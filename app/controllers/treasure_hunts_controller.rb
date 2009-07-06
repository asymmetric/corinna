class TreasureHuntsController < ApplicationController
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

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  # POST /treasure_hunts
  def create
    @hunt = TreasureHunt.new(params[:treasure_hunt])
    if @hunt.save
      flash[:notice] = 'Treasure Hunt was successfully created.'
      redirect_to(@hunt)
    else
      render :action => "new"
    end

    respond_to do |format|
      format.html
      format.fbml
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
end
