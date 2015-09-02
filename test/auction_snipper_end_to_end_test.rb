require "minitest/autorun"

class AuctionSnipperEndToEndTest < Minitest::Test
  def setup
    @auction = FakeAuctionServer.new("item-54321")
    @application = ApplicationRunner.new
  end

  def test_snipper_joins_auction_and_until_auction_closes
    @auction.start_selling_item
    @application.start_bidding_in @auction
    @auction.has_received_join_request_from_snipper
    @auction.announce_closed
    @application.show_snipper_has_lost_auction
  end
end

class FakeAuctionServer
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_RESOURCE = "Auction"
  XMPP_HOSTNAME = "localhost"
  AUCTION_PASSWORD = "auction"

  def initialize(item_id)
    @item_id = item_id
    @connection = XMPPConnection.new
    @message_listener = SingleMessageListener.new
  end

  def start_selling_item
    connection.connect
    connection.login(format_login(ITEM_ID_AS_LOGIN, @item_id), AUCTION_PASSWORD, AUCTION_RESOURCE)
    connection.chat_manager.add_chat_listener(
      ChatManagerListener.new do
        def chat_created(chat, created_locally)
          @current_chat = chat
          chat.add_message_listener message_listener
        end
      end)
  end

  def has_received_join_request_from_snipper
    @message_listener.receive_a_message
  end

  def announce_closed
    @current_chat.send_message(Message.new)
  end

  def stop
    connection.disconnect
  end
end

class SingleMessageListener

  def initialize
    @messages = []
  end

  def process_message(message)
    @messages.add(message)
  end

  def receives_a_message
    # assert pooling of messages every 5 secs
  end
end
