require_relative './xmpp_bot'

class NotifierHook < Redmine::Hook::Listener
  #TODO: it is plans to rename hooks in upstream
  def controller_issues_new_after_save(context={})
    issue = context[:issue]

    deliver(issue) do |user|
      XmppNotificationRenderer.new(context, user).render_issue
    end
  end

  def controller_issues_edit_after_save(context={})
    journal = context[:journal]

    deliver(journal) do |user|
      XmppNotificationRenderer.new(context, user).render_journal
    end
  end

  private

  # @yield [user] The block generates message text for each recepient
  # @yieldparam [User] user
  # @yieldreturn [String] message text
  def deliver(object)
    notification_recipients = notification_recipients(object)
    return if notification_recipients.empty?

    Rails.logger.info "Sending XMPP notification to: #{notification_recipients.map(&:xmpp_jid).join(', ')}"
    notification_recipients.each do |user|
      message = yield(user)
      Bot.deliver user.xmpp_jid, message
    end
  end

  def notification_recipients(object)
    notification_recipients = object.notified_users
    notification_recipients += object.notified_watchers if config["send_to_watchers"]
    notification_recipients.uniq!
    notification_recipients.keep_if {|user| user.xmpp_jid.present? }
    if notification_recipients.any?
      author = object.try(:user) || object.try(:author)
      notification_recipients.delete(author) if author.logged? && author.pref.no_self_notified
    end
    notification_recipients
  end

  def config
    Setting.plugin_redmine_xmpp_notifications
  end
end
