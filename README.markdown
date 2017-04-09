# XMPP Notifications Plugin for Redmine

This plugin is intended to provide integration with XMPP messenger (Jabber).

Following actions will result in notifications to Jabber:

- Create and update issues

Following commands hardcoded into the bot (underscores and angle brackets here for logical grouping purposes only):
- `+#XXXXX <any_message_you_want_to_set_as_comment_for_issue_number_XXXXX>`
- `.#XXXXX <new_status_for_issue_number_XXXXX>`
  + statuses are: `not`, `yet`, `decided`
- `!# <description> +<project_name_substring_or_id> [!<assigned_to>]* [@<watcher>]*`
  + if `assigned_to` is not specified issue will be assigned to the user who sent command
  + `project_name_substring_or_id` can contain spaces. In that case it should be surrounded in `"double quotes"`

## Installation & Configuration

- Then install the Plugin following the general Redmine [plugin installation instructions](http://www.redmine.org/wiki/redmine/Plugins).
- The XMPP Notifications Plugin depends on the [Xmpp4r](https://xmpp4r.github.io/). This can be installed with `bundler` in top Redmine directory:
```
cd <redmine_installation_directory>
bundle install
```
- Go to the Plugins section of the Administration page, select Configure.
- On this page fill out the Jabber ID and password for user who will send messages.
- If you want bot to go online when Redmine starts set `XMPP_BOT_STARTUP` environment variable to any value.
- Restart your Redmine web servers (e.g. mongrel, thin, mod_rails).

## TODO
- Allow notifications to be sent after using bot commands
- Move all bot logic into background process (possibly via `Sidekiq`) and use them via asynchronous background jobs
- Make all commands configurable via Web interface.
