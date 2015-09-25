require 'byebug'
require "minitest/autorun"
require 'xmpp4r/client'
require 'pstore'
require 'capybara/poltergeist'
require File.expand_path '../test_helper.rb', __FILE__
include Jabber

# Jabber::debug = true

class AuctionSnipperEndToEndTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Assertions

  def setup
    @item_id = "item-54321"
    Capybara.configure do |config|
      config.run_server = false
      config.default_driver = :poltergeist
      config.app_host = "http://localhost:4567"
    end
    @auction = FakeAuctionServer.new(@item_id)
    @application_runner = ApplicationRunner.new
  end

  def test_snipper_joins_auction_and_until_auction_closes
    @auction.start_selling_item
    visit "/start-bidding-in/#{@item_id}"
    assert page.has_content? "Joining"
    @auction.has_received_join_request_from_snipper
    @auction.announce_closed
    assert page.has_content? "Lost"
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
    @sender = nil
    @sniper = PStore.new("auction")
  end

  def start_selling_item
    @connection.connect
    @connection.auth(AUCTION_PASSWORD)
    @connection.send(Presence.new)

    @connection.add_message_callback do |msg|
      # TODO: Handle client petition
      pass
    end
  end

  def has_received_join_request_from_snipper
    @message_listener.receives_a_message
  end

  def announce_closed
    jid = JID.new("sniper", "localhost", "Auction")
    @connection.send(Message.new(jid, "Close!"))
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
       @messages.pop
    end
  end
end

class XMPPConnection < Client
end

class ApplicationRunner
  include Capybara::DSL

  def start_bidding_in_item(item_id)
  end

  def shows_sniper_has_lost_auction
  end
end
