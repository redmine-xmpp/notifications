class IssueUpdatedNotifier
  include Sidekiq::Worker
  include XmppNotificationSender

  def perform(issue_id, journal_id)
    updated_issue(issue: Issue.find(issue_id), journal: Journal.find(journal_id))
  end
end