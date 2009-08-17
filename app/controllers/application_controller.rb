# -*- coding: utf-8 -*-
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  ensure_application_is_installed_by_facebook_user
  before_filter :get_default_server, :get_current_facebook_user
  helper_method :prettyprint_blockinline

  def prettyprint_blockinline(xml, xpath)
    doc = Nokogiri::XML(xml)
    para_syntax = doc.root.namespace.nil? ? "para" : "thunt:para"
    para = doc.root.xpath("#{xpath}/#{para_syntax}")
    pretty = ""
    xslt = Nokogiri::XSLT(File.read("#{RAILS_ROOT}/lib/active_treasure_hunt/prettyprint_blockinline.xslt"))
    para.each { |block| pretty << xslt.apply_to(Nokogiri::XML(block.to_xml)).to_a[1..-1].to_s }
    pretty
  end

  private
  def get_default_server
    unless @default_server = Server.find("rené")
      @default_server = Server.new(:id => "rené", :title => "René", :url => "http://xanadu.doesntexist.com/rene")
      @default_server.save
    end
  end
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
