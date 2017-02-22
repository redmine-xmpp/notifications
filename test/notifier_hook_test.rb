require File.expand_path('../test_helper', __FILE__)

class NotifierHookTest <  ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :issues, :journals, :journal_details, :enabled_modules,
           :trackers, :issue_statuses, :enumerations, :custom_values, :projects_trackers

  test 'it delivers to watchers' do
    user = User.generate!(xmpp_jid: 'name@jabberserver.tld')
    issue = Issue.first
    Watcher.create!(watchable: issue, user: user)

    message = <<-TXT
Issue was updated: #1

Author of changes: Redmine Admin
Subject: Cannot print recipes
URL: #{Setting[:protocol]}://#{Setting[:host_name]}/issues/#{issue.id}
Project: eCookbook
Tracker: Bug
Priority: Low
Start date: #{issue.start_date.strftime('%d.%m.%Y')}
Due date: #{issue.due_date.strftime('%d.%m.%Y')}
% Done: 0%
Status: New


Journal notes
    TXT
    Bot.expects(:deliver).with('name@jabberserver.tld', message.strip)

    NotifierHook.instance.controller_issues_edit_after_save(
      issue:   issue,
      journal: issue.journals.first
    )
  end
end