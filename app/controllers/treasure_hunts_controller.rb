class TreasureHuntsController < ApplicationController
  def index
    @hunts = TreasureHunt.find(:all)
  end

  def new
    @hunt = TreasureHunt.new
  end

  def show
    @hunt = TreasureHunt.find(params[:id])
  end

  def subscribe
    @hunt = TreasureHunt.find(params[:id])
  end
end
