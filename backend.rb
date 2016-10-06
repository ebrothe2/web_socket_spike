require 'faye/websocket'

class ChatBackend
  KEEPALIVE_TIME = 15
  def initialize(app)
    @app = app
    @clients = []
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      web_socket = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
      web_socket.on :open do |event|
         p [:open, web_socket.object_id]
         @clients << web_socket
      end

      web_socket.on :message do |event|
        p [:message, event.data]
        @clients.each {|client| client.send(event.data) }
      end

      web_socket.on :close do |event|
        p [:close, web_socket.object_id, event.code, event.reason]
        @clients.delete(web_socket)
        web_socket = nil
      end

      web_socket.rack_response
    else
      @app.call(env)
    end

  end
end