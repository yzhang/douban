module DoubanHelper
  def douban
    @douban ||= (session[:douban] && session[:douban][:access_token]) ? Douban.load(session[:douban]) : nil
  end
  
  def douban_authorized?
    !douban.nil?
  end
  
  def douban_auth_required
    douban_authorized? || redirect_to(douban_auth_path)
  end
  
  def douban_auth_or_login_required
    douban_authorized? || login_required
  end
  
  def self.included(base)
    base.send :helper_method, :douban_authorized? if base.respond_to? :helper_method
  end
end