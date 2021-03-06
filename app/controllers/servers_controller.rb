class ServersController < ApplicationController
  layout "list"
  # GET /treasure_hunts
  def index
    @servers = Server.find(:all)

    respond_to do |format|
      format.fbml
    end
  end

  def new
    @server = Server.new(:title => "", :url => "")

    respond_to do |format|
      format.fbml
    end
  end

  def create
    @server = Server.new(params[:server])
    @server.id = @server.title.strip.tr(" ", "_").downcase[0..15]
    respond_to do |format|
      if @server.save
        User.find(:all).each do |user|
          user.servers << { :id => @server.id, :thunts => [] }
          user.save
        end
        flash[:notice] = 'Server was successfully created.'
        format.fbml { redirect_to @server }
      else
        format.fbml { render :action => :new }
      end
    end
  end

  def edit
    @server = Server.find(params[:id])
  end

  def show
    @server = Server.find(params[:id])

    respond_to do |format|
      format.fbml
    end    
  end

  def update
    @server = Server.find(params[:id])

    respond_to do |format|
      if @server != @default_server and @current_user.is_site_admin? and @server.update_attributes(params[:server])
        flash[:notice] = 'Server was successfully updated.'
        format.fbml { redirect_to @server }
      else
        format.fbml { render :action => :edit }
      end
    end
  end

  def destroy
    @server = Server.find(params[:id])
    @server.destroy unless @default_server == @server or (not @current_user.is_site_admin?)

    respond_to do |format|
      format.fbml { redirect_to servers_url }
    end
  end
end
