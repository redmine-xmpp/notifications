require File.expand_path('../../test_helper', __FILE__)

class NotifierHookTest <  ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :issues, :journals, :journal_details,
           :enabled_modules, :trackers, :issue_statuses, :enumerations, :custom_values, :projects_trackers, :boards,
           :messages, :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions, :custom_fields


  def user
    @user ||= User.generate!(xmpp_jid: 'name@jabberserver.tld')
  end

  test '#controller_issues_edit_after_save delivers to watchers' do
    issue = Issue.first
    Watcher.create!(watchable: issue, user: user)

    message = <<-TXT
Issue #1 has been updated by Redmine Admin.

    - Status changed from New to Assigned
    - % Done changed from 40 to 30

Journal notes

----------------------------------------

Bug #1: Cannot print recipes

Author: John Smith
URL: #{Setting[:protocol]}://#{Setting[:host_name]}/issues/#{issue.id}
Project: eCookbook
Tracker: Bug
Priority: Low
Start date: #{issue.start_date.strftime('%d.%m.%Y')}
Due date: #{issue.due_date.strftime('%d.%m.%Y')}
% Done: 0%
Status: New
    TXT
    Bot.expects(:deliver).with('name@jabberserver.tld', message.strip)

    NotifierHook.instance.controller_issues_edit_after_save(
      issue:   issue,
      journal: issue.journals.first
    )
  end

  test '#controller_issues_edit_after_save respects locale' do
    user = User.generate!(xmpp_jid: 'name@jabberserver.tld', language: :ru)
    issue = Issue.first
    Watcher.create!(watchable: issue, user: user)

    message = <<-TXT
Задача #1 была обновлена (Redmine Admin).

    - Параметр Статус изменился с New на Assigned
    - Параметр Готовность изменился с 40 на 30

Journal notes

----------------------------------------

Bug #1: Cannot print recipes

Автор: John Smith
URL: #{Setting[:protocol]}://#{Setting[:host_name]}/issues/#{issue.id}
Проект: eCookbook
Трекер: Bug
Приоритет: Low
Дата начала: #{issue.start_date.strftime('%d.%m.%Y')}
Дата завершения: #{issue.due_date.strftime('%d.%m.%Y')}
Готовность: 0%
Статус: New
    TXT
    Bot.expects(:deliver).with('name@jabberserver.tld', message.strip)

    NotifierHook.instance.controller_issues_edit_after_save(
      issue:   issue,
      journal: issue.journals.first
    )
  end

  test '#controller_issues_edit_after_save doesn\'t report own actions if preference is set' do
    issue = Issue.first
    journal = issue.journals.second
    author = journal.user
    author.pref.update(no_self_notified: true)
    author.update(xmpp_jid: 'name@jabberserver.tld')

    Bot.expects(:deliver).never

    NotifierHook.instance.controller_issues_edit_after_save(
      issue:   issue,
      journal: journal
    )
  end

  test "#controller_wiki_edit_after_save delivers to wiki page watchers" do
    wiki_page = WikiPage.first
    Watcher.create!(watchable: wiki_page, user: user)

    message = <<-TXT
The 'CookBook documentation' wiki page has been updated by Redmine Admin.
Gzip compression activated

CookBook documentation:
http://localhost:3000/projects/ecookbook/wiki/CookBook_documentation
View differences:
http://localhost:3000/projects/ecookbook/wiki/CookBook_documentation/3/diff
    TXT

    Bot.expects(:deliver).with('name@jabberserver.tld', message.strip)

    NotifierHook.instance.controller_wiki_edit_after_save(page: wiki_page)
  end

  test "#controller_messages_new_after_save delivers to board watchers" do
    message = Message.first
    Watcher.create!(watchable: message.board, user: user)

    xmpp_message = <<-TXT
http://localhost:3000/boards/1/topics/1
Redmine Admin

This is the very first post
in the forum
    TXT

    Bot.expects(:deliver).with('name@jabberserver.tld', xmpp_message.strip)

    NotifierHook.instance.controller_messages_new_after_save(message: message)
  end

  test "#controller_messages_new_after_save delivers to topic watchers" do
    message = Message.where.not(parent_id: nil).first
    Watcher.create!(watchable: message.parent, user: user)

    xmpp_message = <<-TXT
http://localhost:3000/boards/1/topics/1?r=2#message-2
Redmine Admin

Reply to the first post
    TXT

    Bot.expects(:deliver).with('name@jabberserver.tld', xmpp_message.strip)

    NotifierHook.instance.controller_messages_new_after_save(message: message)
  end
end