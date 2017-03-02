require File.expand_path('../../test_helper', __FILE__)

require 'minitest/mock'

class BotTest <  ActiveSupport::TestCase
  def before_setup
    Bot.instance_variable_set(:@singleton__instance__, nil)
    super
  end

  test 'regular expression for mentions accepts project names' do
    assert_not Bot.mentions_regexp.match('project+myproject').nil?
    assert_not Bot.mentions_regexp.match('project+my_project').nil?
    assert_not Bot.mentions_regexp.match('project+my-project').nil?
    assert_not Bot.mentions_regexp.match('project+"myproject"').nil?
    assert_not Bot.mentions_regexp.match('project+"my_project"').nil?
    assert_not Bot.mentions_regexp.match('project+"my-project"').nil?
  end

  [
      Errno::ECONNREFUSED,
      Errno::ENETUNREACH, # this may happen if the network interface gone down while bot was sending a message
      Jabber::JabberError,
      SocketError,
      Errno::ETIMEDOUT,
      IOError
  ].each do |exception_class|
    test "#deliver method rescues from #{exception_class}" do
      client = Object.new
      client.expects(:send).raises(exception_class)
      Bot.instance.expects(:client).returns(client)
      Bot.instance.deliver("id@example.com", "hello")
    end

    test "#client method returns nil when there is #{exception_class}" do
      Jabber::Client.any_instance.expects(:connect).raises(exception_class)
      assert Bot.instance.client.nil?
    end
  end
end