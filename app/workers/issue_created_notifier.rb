class IssueCreatedNotifier
  include Sidekiq::Worker
  include XmppNotificationSender

  def perform(issue_id)
    new_issue(issue: Issue.find(issue_id))
  end
end