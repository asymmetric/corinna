class ServersController < ApplicationController
  
  # GET /treasure_hunts
  def index
    @servers = Server.find(:all)

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  def new
    @server = Server.new(:title => "", :url => "")

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  def create
    @server = Server.new(params[:server])
    @server.id = @server.title.downcase[0..10]
    respond_to do |format|
      if @server.save
        flash[:notice] = 'Server was successfully created.'
        format.html { redirect_to @server }
        format.fbml { redirect_to @server }
      else
        format.html { render :action => :new }
        format.fbml { render :action => :new }
      end
    end
  end

  def edit
    @server = Server.find(params[:id])
    #respond_to do |format|
    #  format.html
    #  format.fbml
    #end
  end

  def show
    @server = Server.find(params[:id])

    respond_to do |format|
      format.html
      format.fbml
    end    
  end

  def update
    @server = Server.find(params[:id])

    respond_to do |format|
      if @server.update_attributes(params[:server])
        flash[:notice] = 'Server was successfully updated.'
        format.html { redirect_to @server }
        format.fbml { redirect_to @server }
      else
        format.html { render :action => :edit }
        format.fbml { render :action => :edit }
      end
    end
  end

  def destroy
    @server = Server.find(params[:id])
    @server.destroy

    respond_to do |format|
      format.html { redirect_to servers_url }
      format.fbml { redirect_to servers_url }
    end
  end
end
