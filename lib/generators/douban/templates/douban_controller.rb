class DoubanController < ApplicationController
  def new
    douban = Douban.new
    douban.callback = douban_callback_url
    authorize_url = douban.authorize_url
    
    respond_to do |wants|
      session[:back]   = request.env['HTTP_REFERER'] unless request.env['HTTP_REFERER'].blank?
      session[:douban] = douban.dump
      wants.html {redirect_to authorize_url}
    end
  end
  
  def callback
    if session[:douban]
      douban = Douban.load(session[:douban])
      douban.authorize
      session[:douban] = douban.dump
    end
    
    redirect_to(session[:back] || '/')
    session[:back] = nil
  end
  
  def destroy
    return unless douban_authorized?
    session[:douban] = nil
    douban.destroy
    redirect_to '/'
  end
end