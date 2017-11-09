class NotifierHook < Redmine::Hook::Listener
  include XmppNotificationSender

  #TODO: it is plans to rename hooks in upstream
  def controller_issues_new_after_save(context={})
    dispatch(:new_issue, context)
  end

  def controller_issues_edit_after_save(context={})
    dispatch(:updated_issue, context)
  end

  def controller_wiki_edit_after_save(context={})
    dispatch(:updated_wiki, context)
  end

  def controller_messages_new_after_save(context={})
    dispatch(:message, context)
  end

  alias_method :controller_messages_reply_after_save, :controller_messages_new_after_save
end
