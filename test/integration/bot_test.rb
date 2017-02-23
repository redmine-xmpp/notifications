require File.expand_path('../../test_helper', __FILE__)

require 'minitest/mock'

class BotTest <  ActiveSupport::TestCase
  test 'regular expression for mentions accepts project names' do
    assert_not Bot.mentions_regexp.match('project+myproject').nil?
    assert_not Bot.mentions_regexp.match('project+my_project').nil?
    assert_not Bot.mentions_regexp.match('project+my-project').nil?
    assert_not Bot.mentions_regexp.match('project+"myproject"').nil?
    assert_not Bot.mentions_regexp.match('project+"my_project"').nil?
    assert_not Bot.mentions_regexp.match('project+"my-project"').nil?
  end

  test '#client method returns nil when there is no network connection' do
    Jabber::Client.any_instance.expects(:connect).raises(Errno::ENETUNREACH)
    assert Bot.instance.client.nil?
  end

  test '#client method returns nil when there is a jabber error (e.g. bad password)' do
    Jabber::Client.any_instance.expects(:connect).raises(Jabber::JabberError)
    assert Bot.instance.client.nil?
  end

  test '#client method returns nil when there is a socket error' do
    Jabber::Client.any_instance.expects(:connect).raises(SocketError)
    assert Bot.instance.client.nil?
  end

  # this may happen if the network interface gone down while bot was sending a message
  test '#deliver method rescues from Errno::ENETUNREACH' do
    client = Minitest::Mock.new
    client.expect(:tap, client)
    client.expect(:send, nil) { raise Errno::ENETUNREACH }
    Bot.instance.expects(:client).returns(client)
    Bot.instance.deliver("id@example.com", "hello")
  end

  test '#deliver method rescues from Jabber::JabberError' do
    client = Minitest::Mock.new
    client.expect(:tap, client)
    client.expect(:send, nil) { raise Jabber::JabberError }
    Bot.instance.expects(:client).returns(client)
    Bot.instance.deliver("id@example.com", "hello")
  end

  test '#deliver method rescues from SocketError' do
    client = Minitest::Mock.new
    client.expect(:tap, client)
    client.expect(:send, nil) { raise SocketError }
    Bot.instance.expects(:client).returns(client)
    Bot.instance.deliver("id@example.com", "hello")
  end
end