# -*- coding: utf-8 -*-
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  before_filter :get_default_server
  private
  def get_default_server
    unless @default_server = Server.find("rené")
      @default_server = Server.new(:id => "rené", :title => "René", :url => "http://xanadu.doesntexist.com/rene")
      @default_server.save
    end
  end
end
