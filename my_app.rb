require 'rubygems'
require 'sinatra'
require 'xmpp4r/client'
include Jabber

get '/' do
  @status = ""
  haml :index
end

get '/start-bidding-in/:item_id' do |item_id|
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_RESOURCE = "Auction"
  AUCTION_ID_FORMAT = "#{ITEM_ID_AS_LOGIN}@localhost/#{AUCTION_RESOURCE}"

  jid = JID.new("sniper", "localhost", AUCTION_RESOURCE)
  connection = Client.new(jid)
  connection.auth("sniper")

  chat = connection.chat_manager.create_chat(AUCTION_ID_FORMAT,
                                             Class.new do
                                               def process_message(a_chat, message)
                                                 # nothing yet
                                               end
                                             end
                                            )
  chat.send_message(Message.new)
  '<span>Joining</span>'
end

def connect_to(hostname, username, password)
  jid = JID.new(username, hostname, AUCTION_RESOURCE)
  connection = XMPPConnection.new(jid)
  connection.auth(password)
  connection
end

def auction_id
  # TODO
end
