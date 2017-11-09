require "redmine"
require "xmpp4r"

require_dependency "xmpp_bot"
require_dependency "notifier_hook"
require_dependency "my_account_hooks"
#require_dependency "issue" #TODO
require_dependency "user_hooks"
require_dependency "user"

if User.const_defined? "SAFE_ATTRIBUTES"
  User::SAFE_ATTRIBUTES << "xmpp_jid"
else
  User.safe_attributes "xmpp_jid"
end

Redmine::Plugin.register :redmine_xmpp_notifications do
  name "Redmine XMPP Notifications plugin"
  author "Pavel Musolin & Vadim Misbakh-Soloviov & Yokujin Yokosuka & Others"
  description "A plugin to send Redmine Activity and receive commands over XMPP"
  version "2.1.0"
  url "https://github.com/redmine-xmpp/notifications"

  settings default: {
      "jid" => "", "password" => "", "send_to_watchers" => true, "use_sidekiq" => false
  }, partial: "settings/xmpp_settings"
end

Rails.logger.info "#{'*'*65}\n* XMPP Bot init.rb\n#{'*'*65}"


# Start bot only when XMPP_BOT_STARTUP env var is set
ENV['XMPP_BOT_STARTUP'] && Rails.configuration.to_prepare do
  Rails.logger.info "#{'*'*65}\n* XMPP_BOT_STARTUP env var exists - requesting bot startup\n#{'*'*65}"

  Bot.ping
end
