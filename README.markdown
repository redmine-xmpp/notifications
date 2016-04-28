# XMPP Notifications Plugin for Redmine

This plugin is intended to provide _not so_ basic integration with XMPP messenger (Jabber).
Following actions will result in notifications to Jabber:

- Create and update issues

## Installation & Configuration

- The XMPP Notifications Plugin depends on the [Xmpp4r](https://xmpp4r.github.io/). This can be installed with `bundler` in top Redmine directory:
```
cd <redmine_installation_directory>
bundle install
```
- Then install the Plugin following the general Redmine [plugin installation instructions](http://www.redmine.org/wiki/redmine/Plugins).
- Go to the Plugins section of the Administration page, select Configure.
- On this page fill out the Jabber ID and password for user who will send messages.
- Restart your Redmine web servers (e.g. mongrel, thin, mod_rails).
