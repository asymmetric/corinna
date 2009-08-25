class TreasureHuntsController < ApplicationController
  before_filter :get_server
  layout "list"

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
        user_serv = @current_user.find_server @server.id
        user_serv.thunts << { :id => @hunt.id, :password => hunt_pwd }
        @current_user.save
        flash[:notice] = 'Treasure Hunt successfully created!'
        format.html { redirect_to [@server, @hunt] }
        format.fbml { redirect_to [@server, @hunt] }
      rescue ActiveTreasureHunt::XMLError => e
        flash[:error] = e.message
        @hunt.xml = ""
        format.html { render :action => :new }
        format.fbml { render :action => :new }
      end
    end

  end

  # GET /treasure_hunts/1
  def show
    respond_to do |format|
      begin
        #TreasureHunt.set_site = Server.find(params[:server]).url
        @hunt = TreasureHunt.find(params[:id])
        format.html
        format.fbml
      rescue ActiveTreasureHunt::XMLError => e
        flash[:error] = e.message
        format.html { redirect_to :controller => :list }
        format.fbml { redirect_to :controller => :list }
      end
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
        format.html { redirect_to [@server, @hunt] }
        format.fbml { redirect_to [@server, @hunt] }
      end
    end
  end

  def fakehint
    respond_to do |format|
      if request.get?
        @hunt = TreasureHunt.find params[:id]

        begin
          resp = @hunt.status @current_user.id, @current_user.password
          xml = Nokogiri::XML resp
          @status = xml.root.xpath 'thunt:status'
          @turns = xml.root.xpath('thunt:status/@turnNumber').to_a
          @turn_names = xml.root.xpath('thunt:status/@turnName')
        rescue ActiveTreasureHunt::XMLError => e
          @status = e
        end

        format.html
        format.fbml
       elsif request.post?
         begin
           @hunt = TreasureHunt.find params[:id]
           @turn = params[:turn]
           @fake_hint = params[:fakehint]

           @hunt.fakehint @fake_hint, @turn, @current_user.id, @current_user.password
           flash[:notice] = "Fake hint successfully sent!"
           format.html { redirect_to [@server, @hunt] }
           format.fbml { redirect_to [@server, @hunt] }
         rescue ActiveTreasureHunt::XMLError => e
           flash[:error] = e.message
           format.html { redirect_to [@server, @hunt ] }
           format.fbml { redirect_to :action => "hint" }
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
        # @hunt.subscribe :group, group_id, @current_user.password
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
        format.html { redirect_to [@server, @hunt] }
        format.fbml { redirect_to [@server, @hunt] }
      end
    end
  end

  def start
    @hunt = TreasureHunt.find params[:id]

    begin
      hunt_pwd = @current_user.hunt_password @hunt.id, @server.id
      @hint = @hunt.start @current_user.id, hunt_pwd
      flash[:notice] = "Treasure Hunt successfully started!"
    rescue ActiveTreasureHunt::XMLError => e
      flash[:error] = e.message
    end
    respond_to do |format|
      format.html { redirect_to [@server, @hunt] }
      format.fbml { redirect_to [@server, @hunt] }
    end
  end

  def answer
    if request.get?
      @hunt = TreasureHunt.find params[:id]

      # shows form to input the answer
      respond_to do |format|
        format.html
        format.fbml
      end

    elsif request.post?
      @hunt = TreasureHunt.find params[:id]
      answer_type = params[:type]
      answer = {}
      case answer_type
      when "geoloc"
        answer[:lat] = params[:geoloc_lat]
        answer[:long] = params[:geoloc_long]
        answer[:planet] = params[:geoloc_planet]
      when "video"
        case params[:answer]
        when /google/
          answer[:id] = params[:answer].gsub(/.*\?docid=(.*)\&?.*/,'\1')
          answer[:service] = :googlevideo
        when /youtube/
          answer[:id] = params[:answer].gsub(/.*\?v=([\w]*)\&?.*/,'\1')
          answer[:service] = :youtube
        end
      when "picture"
        answer[:service] = "flickr"
        answer[:usr] = params[:answer].gsub(/.*?(\w*?)\/(\w*?)\/?$/,'\1')
        answer[:id] = params[:answer].gsub(/.*?(\w*?)\/(\w*?)\/?$/,'\2')
      else
        answer = params[:answer]
      end
      respond_to do |format|

        begin
          response = Nokogiri::Slop(@hunt.answer(answer, answer_type, @current_user.id, @current_user.password))
          flash[:notice] = case response.root['status']
                           when "wrong" then "This is not the correct answer, try again!"
                           when "right" then "You got it right!"
                           when "win" then "Congratulations! You won the Treasure Hunt!"
                           when "lose" then "You lose!"
                           end
          flash[:info] = prettyprint_blockinline(response.root.to_xml, '.').strip[0..200].gsub(/<[^>]*$/,'...').gsub(/(<\/?img)(.*?>)/,'\1 style="width:auto; height:15em;" \2').gsub(/<\/?p.*?>/,'')
          format.html { redirect_to :action => :hint }
          format.fbml { redirect_to :action => :hint }
        rescue Nokogiri::XML::SyntaxError => e
          flash[:error] = "This is not a valid answer!"
          format.html
          format.fbml
        end
      end
    end
  end

  # DELETE /treasure_hunts/1
  def destroy
    @hunt = TreasureHunt.find(params[:id])
    begin
      @hunt.destroy(@current_user.id, @current_user.hunt_password(@hunt.id, @server.id))
      @current_user.find_server(@server.id).thunts.delete_if { |x| x.id == @hunt.id }
      @current_user.save
      flash[:notice] = "Treasure Hunt successfully destroyed!"
    rescue ActiveTreasureHunt::XMLError => e
      flash[:error] = e.message
    end

    respond_to do |format|
      format.html { redirect_to :controller => :list }
      format.fbml { redirect_to :controller => :list }
    end
  end

  def invite
    @hunt = TreasureHunt.find params[:id]

    respond_to do |format|
      format.html
      format.fbml
    end
  end

  private
  def get_server
    @server = Server.find(params[:server_id])
    TreasureHunt.site = @server.url
    TreasureHunt.prefix = "#{TreasureHunt.site.path}/"
  end
end
