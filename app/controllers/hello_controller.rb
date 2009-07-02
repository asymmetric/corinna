class HelloController < ApplicationController
  def index
    respond_to do |format|
      format.fbml # index.fbml.erb
#      format.xml  { render :xml => @airplanes }
    end
  end
end
