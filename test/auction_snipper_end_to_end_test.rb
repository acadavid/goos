require 'byebug'
require "minitest/autorun"
require 'xmpp4r/client'
require File.expand_path '../test_helper.rb', __FILE__
include Jabber

Jabber::debug = true

class AuctionSnipperEndToEndTest < Minitest::Test
  include Capybara::DSL

  def setup
    @item_id = "item-54321"
    Capybara.app = Sinatra::Application.new
    @auction = FakeAuctionServer.new(@item_id)
    @application = Capybara.app
  end

  def test_snipper_joins_auction_and_until_auction_closes
    @auction.start_selling_item
    visit "/start-bidding-in/#{@item_id}"
    #byebug
    page.has_content? "Joining"
    @auction.has_received_join_request_from_snipper
    @auction.announce_closed
    page.must_have_content "Lost"
  end
end

class FakeAuctionServer

  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_RESOURCE = "Auction"
  XMPP_HOSTNAME = "localhost"
  AUCTION_PASSWORD = "auction"

  def initialize(item_id)
    @item_id = item_id
    jid = JID.new(ITEM_ID_AS_LOGIN % @item_id, XMPP_HOSTNAME, AUCTION_RESOURCE)
    @connection = XMPPConnection.new(jid)
    @message_listener = SingleMessageListener.new
  end

  def start_selling_item
    @connection.connect
    @connection.auth(AUCTION_PASSWORD)
    listener = Class.new do
      def chat_created(chat, created_locally)
        @current_chat = chat
        chat.add_message_listener @message_listener
      end
    end
    @connection.add_message_callback(listener)
  end

  def has_received_join_request_from_snipper
    @message_listener.receives_a_message
  end

  def announce_closed
    @current_chat.send_message(Message.new)
  end

  def stop
    @connection.disconnect
  end

  def format_login(item_id)
  end

  class SingleMessageListener < Minitest::Test

    def initialize
      @messages = []
    end

    def process_message(message)
      @messages.add(message)
    end

    def receives_a_message
      refute_nil @messages.pop
    end
  end
end

class XMPPConnection < Client
end
