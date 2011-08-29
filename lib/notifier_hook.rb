class NotifierHook < Redmine::Hook::Listener
  
  def controller_issues_new_after_save(context={})
    redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
    issue = context[:issue]

    text = "#{issue.author.name} created issue ##{issue.id} #{issue.subject} \n"
    text += "URL: #{redmine_url}/issues/#{issue.id} \n"
    text += "Tracker: #{issue.tracker.name} \n"
    text += "Priority: #{issue.priority.name} \n"
    if issue.assigned_to
      text += "Assigned to: #{issue.assigned_to.name} \n"
    end
    if issue.start_date
      text += "Start: #{issue.start_date.strftime("%e %B %Y")} \n"
    end
    if issue.due_date
      text += "Due: #{issue.due_date.strftime("%e %B %Y")} \n"
    end
    if issue.estimated_hours
      text += "Estimated time: #{issue.estimated_hours} hours \n"
    end
    if issue.done_ratio
      text += "Done: #{issue.done_ratio} % \n"
    end
    text += "\n\n#{issue.description}"

    deliver text, issue
  end
  
  def controller_issues_edit_after_save(context={})
    redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
    issue = context[:issue]
    journal = context[:journal]

    text = "#{journal.user.name} updated issue ##{issue.id} #{issue.subject} \n"
    text += "URL: #{redmine_url}/issues/#{issue.id} \n"
    text += "Tracker: #{issue.tracker.name} \n"
    text += "Priority: #{issue.priority.name} \n"
    if issue.assigned_to
      text += "Assigned to: #{issue.assigned_to.name} \n"
    end
    if issue.start_date
      text += "Start: #{issue.start_date.strftime("%e %B %Y")} \n"
    end
    if issue.due_date
      text += "Due: #{issue.due_date.strftime("%e %B %Y")} \n"
    end
    if issue.estimated_hours
      text += "Estimated time: #{issue.estimated_hours} hours \n"
    end
    if issue.done_ratio
      text += "Done: #{issue.done_ratio} % \n"
    end
    text += "\n\n#{journal.notes}"

    deliver text, issue
  end
  
  
  private
  
  
  def deliver(message, issue)
    config = Setting.plugin_redmine_xmpp_notifications
    client = Jabber::Simple.new config["jid"], config["jidpassword"]
    User.active.each do |user|
      client.deliver(user.xmpp_jid, message) if user.xmpp_jid != "" && user.notify_about?(issue)
    end
  end
  
end