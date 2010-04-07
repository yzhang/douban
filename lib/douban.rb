require 'oauth'

class Douban
  attr_accessor :callback, :request_token, :access_token
  
  class << self
    def load(data)
      access_token        = data[:access_token]
      access_token_secret = data[:access_token_secret]
    
      douban               = Douban.new(data[:request_token], data[:request_token_secret])
      douban.access_token  = OAuth::AccessToken.new(api_consumer, access_token, access_token_secret) if access_token
      douban
    end

    def auth_consumer
      @@auth_consumer ||= OAuth::Consumer.new(key, secret, {
          :signature_method   => "HMAC-SHA1",
          :site               => "http://www.douban.com",
          :scheme             => :header,
          :request_token_path => '/service/auth/request_token',
          :access_token_path  => '/service/auth/access_token',
          :authorize_path     => '/service/auth/authorize',
          :realm              => url
         })
    end
  
    def api_consumer
      @@api_consumer ||= OAuth::Consumer.new(key, secret,
        {
          :site             => "http://api.douban.com",
          :scheme           => :header,
          :signature_method => "HMAC-SHA1",
          :realm            => url
        })
    end
    
    def key; config['key'];  end
    def secret; config['secret']; end
    def url; config['url']; end
    
    def config
      @@config ||= lambda do
        require 'yaml'
        filename = "#{Rails.root}/config/douban.yml"
        file     = File.open(filename)
        yaml     = YAML.load(file)
        return yaml[Rails.env]
      end.call
    end
  end
  
  def initialize(request_token = nil, request_token_secret = nil)
    if request_token && request_token_secret
      self.request_token = OAuth::RequestToken.new(self.class.auth_consumer, request_token, request_token_secret)
    else
      self.request_token = self.class.auth_consumer.get_request_token()
    end
  end
  
  def authorize_url
    @authorize_url ||= request_token.authorize_url(:oauth_callback => self.callback)
  end
  
  def authorize
    return unless self.access_token.nil?
    
    access_token = self.request_token.get_access_token
    self.access_token ||= OAuth::AccessToken.new(self.class.api_consumer, access_token.token, access_token.secret)
  end
  
  def authorized?
    return false if access_token.nil?
    response = self.get("/access_token/#{access_token.token}")
    response.code == '200'
  end
  
  def destroy
    destroy_access_key if !access_token.nil?
    request_token = access_token = nil
  end

  def dump
    {
      :request_token        => request_token.token, 
      :request_token_secret => request_token.secret,
      :access_token         => access_token.nil? ? nil : access_token.token,
      :access_token_secret  => access_token.nil? ? nil : access_token.secret
    }
  end
  
  def request(http_method, path, headers = {})
    access_token.request(http_method, path, headers)
  end
    
  def get(path, headers = {})
    request(:get, path, headers)
  end
  
  def post(path, headers = {})
    request(:post, path, headers)
  end
    
  def delete(path, headers = {})
    request(:delete, path, headers)
  end
  
  def put(path, headers = {})
    request(:put, path, headers)
  end
  
  protected
  
  def destroy_access_key
    response = delete("/access_token/#{access_token.token}")
    response.code == '200'
  end
end
