require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra-websocket'
require './models.rb'

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
  settings.sockets.each do |s|
        s.send(Count.first.number.to_s)
    end
    return 'hoge'
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
