require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra-websocket'
require './models.rb'
require 'open-uri'
require 'net/http'

set :server, 'thin'
set :sockets, []
enable :sessions

before do
  if Count.all.length == 0
    Count.create(number: 0)
  end
end


get '/' do
  erb :top
end

get '/sakura' do
  erb :index
end

post '/join' do
  count = Count.first
  count.number = count.number + 1
  count.save
  session[:number] = count.number
  redirect '/sakura'
end

get '/finish' do
  Count.first.delete
  redirect '/'
end

get '/vertical' do
    token = '5DS8pknAnIAKtJZ4LjFmFYCRFecRI6Y06XjemVRIbVI.jCiyqthBBGTAE2xLQPVaqbkzKs7gcv5uHHUMVxBxqkY'
    signal = '29f8db97-4f7d-48cc-a2dc-4baf8777d10a'
    uri = URI.parse("https://api.nature.global/1/signals/#{signal}/send")
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Post.new(uri.request_uri)
    req["Authorization"] = "bearer #{token}"
    req["Accept"] = "application/json"
    req["Content-Type"] = "application/x-www-form-urlencoded"


    res = http.request(req)
    puts res.code, res.msg
    puts res.body

    settings.sockets.each do |s|
        s.send(Count.first.number.to_s)
    end
end

get '/horizontal' do
  settings.sockets.each do |s|
        s.send("ver")
    end
    return 'hoge'
end

get '/websocket' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        settings.sockets.each do |s|
          s.send(msg)
        end
      end
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  end
end
