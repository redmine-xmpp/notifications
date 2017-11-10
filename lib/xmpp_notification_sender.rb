module XmppNotificationSender
  def dispatch(notification_type, context)
    config["use_sidekiq"] ? submit_a_job(notification_type, context) : public_send(notification_type, context)
  end

  def new_issue(context)
    issue = context[:issue]

    deliver(issue) do |user|
      IssueNotificationView.new(context, user).render_issue
    end
  end

  def updated_issue(context)
    journal = context[:journal]

    deliver(journal) do |user|
      IssueNotificationView.new(context, user).render_journal
    end
  end

  def updated_wiki(context)
    page = context[:page]

    deliver(page.content) do |user|
      WikiNotificationView.new(context, user).render
    end
  end

  def message(context={})
    message = context[:message]

    deliver(message) do |user|
      MessageNotificationView.new(context, user).render
    end
  end

  private

  def verify_sidekiq_presence
    return if Object.const_defined?("Sidekiq")
    raise "Sidekiq is not present! Install redmine_sidekiq plugin or disable background processing."
  end

  def submit_a_job(notification_type, context)
    verify_sidekiq_presence
    case notification_type
      when :new_issue
        IssueCreatedNotifier.perform_async(context[:issue].id)
      when :updated_issue
        IssueUpdatedNotifier.perform_async(context[:issue].id, context[:journal].id)
      when :updated_wiki
        WikiUpdatedNotifier.perform_async(context[:page].id)
      when :message
        MessageNotifier.perform_async(context[:message].id)
      else
        raise "Unknown notification type"
    end
  end

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
    notification_recipients += fetch_watchers(object) if config["send_to_watchers"]
    notification_recipients.uniq!
    notification_recipients.keep_if {|user| user.xmpp_jid.present? }
    if notification_recipients.any?
      author = object.try(:user) || object.try(:author)
      notification_recipients.delete(author) if author.logged? && author.pref.no_self_notified
    end
    notification_recipients
  end

  def fetch_watchers(object)
    (object.try(:notified_watchers) || object.page.notified_watchers)
        .concat(message_watchers(object))
  end

  def message_watchers(message)
    return [] unless message.respond_to?(:parent)
    if message.parent.nil?
      message.try(:board).try(:notified_watchers) || []
    else
      message.parent.try(:notified_watchers) || []
    end
  end

  def config
    Setting.plugin_redmine_xmpp_notifications
  end
end