require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require "sinatra/cookies"
require 'httpclient'
require 'json'


def get_token(code)
 url = "https://sandbox.tinypass.com/id/api/v1/identity/token"
 data = {
   "code" => code,
   "client_id" => 'oiGmjC8JwK',
   "client_secret" => ENV['client_secret'],
   "redirect_uri" => 'https://localhost:9292'
 }
  client = HTTPClient.new.post(url, data)
  body = JSON.parse(client.body)
  return body
end

def check_access(token)
  url = "https://sandbox.tinypass.com/api/v3/access/check?"
  data = {
    "aid" => 'oiGmjC8JwK',
    "rid" => 'RQABZ8F'
  }
  header = {'Authorization' => "Bearer '#{token}'"}
  client = HTTPClient.new.get(url, data, header)
  body = JSON.parse(client.body)
  return body
end

class OAuthApp < Sinatra::Base
  helpers Sinatra::Cookies

  get '/' do
    if (params.has_key?(:code))
      @code = params['code']
      @result = get_token(@code)
      @token = @result["access_token"]
       cookies[:token] = @token
     end
    @access = check_access(cookies[:token])

    erb :index
  end

  get '/birds' do
    @access = check_access(cookies[:token])
    erb :birds
  end

  get '/turtles' do
    @access = check_access(cookies[:token])
    erb :turtles
  end

  get '/bears' do
    @access = check_access(cookies[:token])
    erb :bears
  end
end
