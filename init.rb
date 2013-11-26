require "redmine"
require "rubygems"
require "xmpp4r-simple"

require_dependency "notifier_hook"
require_dependency "my_account_hooks"
require_dependency "user_hooks"
require_dependency "user"

if User.const_defined? "SAFE_ATTRIBUTES"
    User::SAFE_ATTRIBUTES << "xmpp_jid"
else
    User.safe_attributes "xmpp_jid"
end

Redmine::Plugin.register :redmine_xmpp_notifications do
  name "Redmine XMPP Notifications plugin"
  author "Pavel Musolin & Vadim Misbakh-Soloviov"
  description "A plugin to sends Redmine Activity over XMPP"
  version "1.0.0"
  url "https://github.com/pmisters/redmine_xmpp_notifications"
  
  settings :default => {"jid" => "", "password" => ""}, :partial => "settings/xmpp_settings"
end
