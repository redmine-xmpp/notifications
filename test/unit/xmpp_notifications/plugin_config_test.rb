require File.expand_path('../../../test_helper', __FILE__)

class PluginConfigTest <  ActiveSupport::TestCase
  class ExampleClass
    include XmppNotifications::PluginConfig
  end

  def instance
    @instance ||= ExampleClass.new
  end

  test '#use_sidekiq? is true when setting is set to "true"' do
    Setting.plugin_redmine_xmpp_notifications["use_sidekiq"] = "true"
    assert instance.use_sidekiq?
  end

  test '#use_sidekiq? is false when setting is nil' do
    Setting.plugin_redmine_xmpp_notifications["use_sidekiq"] = nil
    assert_not instance.use_sidekiq?
  end

  test '#use_sidekiq? is false when setting is empty string' do
    Setting.plugin_redmine_xmpp_notifications["use_sidekiq"] = ''
    assert_not instance.use_sidekiq?
  end

  test '#send_to_watchers? is true when setting is set to "true"' do
    Setting.plugin_redmine_xmpp_notifications["send_to_watchers"] = "true"
    assert instance.send_to_watchers?
  end

  test '#send_to_watchers? is false when setting is nil' do
    Setting.plugin_redmine_xmpp_notifications["send_to_watchers"] = nil
    assert_not instance.send_to_watchers?
  end

  test '#send_to_watchers? is false when setting is empty string' do
    Setting.plugin_redmine_xmpp_notifications["send_to_watchers"] = ''
    assert_not instance.send_to_watchers?
  end
end
