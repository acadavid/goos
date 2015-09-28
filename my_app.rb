require 'rubygems'
require 'sinatra'
require 'pstore'
require 'faye/websocket'
Dir[File.join("./", "lib/*.rb")].each do |f|
  require f
end

Faye::WebSocket.load_adapter('thin')

get '/' do
  @@ws = nil
  @status = ""
  haml :index
end

get '/start-bidding-in/:item_id' do |item_id|
  @status = ""
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_RESOURCE = "Auction"
  AUCTION_ID_FORMAT = "#{ITEM_ID_AS_LOGIN}@localhost/#{AUCTION_RESOURCE}"

  connection = connect_to_xmpp("localhost", "sniper", "sniper")

  auction_data = PStore.new("auction_data.pstore")

  auction_data.transaction do
    auction_data[:status] = "Joining"
  end

  connection.add_message_callback do |msg|
    @@ws.send("Close")
  end

  auction_data.transaction(true) do
    @status = auction_data[:status]
  end

  haml :index
end

get '/ws' do
  if Faye::WebSocket.websocket?(env)
    @@ws = Faye::WebSocket.new(env)

    @@ws.on :message do |event|
      @@ws.send(event.data)
    end

    @@ws.on :close do |event|
      p [:close, event.code, event.reason]
      @@ws = nil
    end

    @@ws.rack_response
  end
end

def connect_to_xmpp(hostname, username, password)
  jid = JID.new(username, hostname, AUCTION_RESOURCE)
  connection = XMPPConnection.new(jid)
  connection.connect
  connection.auth(password)
  connection.send(Presence.new)
  connection
end
