require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []
enable :sessions
get '/' do
  erb :index
end

get '/horizontal' do
  settings.sockets.each do |s|
        s.send("hor")
    end
    return 'hoge'
end

get '/vertical' do
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
