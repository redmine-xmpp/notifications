class IssueNotificationView < XmppNotificationView
  include IssuesHelper

  attr_reader :issue, :journal

  def initialize(context, user)
    @issue = context[:issue]
    @journal = context[:journal]
    super
  end

  def journal_details
    journal.visible_details(user) if journal
  end

  def render_issue
    render(file: "xmpp/issue_add.text.erb")
  end

  def render_journal
    render(file: "xmpp/issue_edit.text.erb")
  end
end