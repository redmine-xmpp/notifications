module XmppNotifications
  module PluginConfig
    def config
      Setting.plugin_redmine_xmpp_notifications
    end

    def use_sidekiq?
      config["use_sidekiq"] == "true"
    end

    def send_to_watchers?
      config["send_to_watchers"] == "true"
    end
  end
end