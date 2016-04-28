require_relative './xmpp_bot'

class NotifierHook < Redmine::Hook::Listener

    def initialize
    end

    #TODO: it is plans to rename hooks in upstream
    def controller_issues_new_after_save(context={})
        redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
        issue = context[:issue]

        text = l(:xmpp_issue_created) + " ##{issue.id}\n\n"
        text += l(:field_author) + ": #{issue.author.name}\n"
        text += l(:field_subject) + ": #{issue.subject}\n"
        text += l(:field_url) + ": #{redmine_url}/issues/#{issue.id}\n"
        text += l(:field_project) + ": #{issue.project}\n"
        text += l(:field_tracker) + ": #{issue.tracker.name}\n"
        text += l(:field_priority) + ": #{issue.priority.name}\n"
        if issue.assigned_to
            text += l(:field_assigned_to) + ": #{issue.assigned_to.name}\n"
        end
        if issue.start_date
            text += l(:field_start_date) + ": #{issue.start_date.strftime("%d.%m.%Y")}\n"
        end
        if issue.due_date
            text += l(:field_due_date) + ": #{issue.due_date.strftime("%d.%m.%Y")}\n"
        end
        if issue.estimated_hours
            text += l(:field_estimated_hours) + ": #{issue.estimated_hours} " + l(:field_hours) + "\n"
        end
        if issue.done_ratio
            text += l(:field_done_ratio) + ": #{issue.done_ratio}%\n"
        end
        if issue.status
            text += l(:field_status) + ": #{issue.status.name}\n"
        end
        text += "\n\n#{issue.description}"

        deliver text, issue
    end

    def controller_issues_edit_after_save(context={})
        redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
        issue = context[:issue]
        journal = context[:journal]

        text = l(:xmpp_issue_updated) + " ##{issue.id}\n\n"
        text += l(:xmpp_update_author) + ": #{journal.user.name}\n"
        text += l(:field_subject) + ": #{issue.subject}\n"
        text += l(:field_url) + ": #{redmine_url}/issues/#{issue.id}\n"
        text += l(:field_project) + ": #{issue.project}\n"
        text += l(:field_tracker) + ": #{issue.tracker.name}\n"
        text += l(:field_priority) + ": #{issue.priority.name}\n"
        if issue.assigned_to
            text += l(:field_assigned_to) + ": #{issue.assigned_to.name}\n"
        end
        if issue.start_date
            text += l(:field_start_date) + ": #{issue.start_date.strftime("%d.%m.%Y")}\n"
        end
        if issue.due_date
            text += l(:field_due_date) + ": #{issue.due_date.strftime("%d.%m.%Y")}\n"
        end
        if issue.estimated_hours
            text += l(:field_estimated_hours) + ": #{issue.estimated_hours} " + l(:field_hours) + "\n"
        end
        if issue.done_ratio
            text += l(:field_done_ratio) + ": #{issue.done_ratio}%\n"
        end
        if issue.status
            text += l(:field_status) + ": #{issue.status.name}\n"
        end
        text += "\n\n#{journal.notes}"

        deliver text, issue
    end


    private

    def deliver(message, issue)
        User.active.each do |user|
            if user.xmpp_jid.nil? || user.xmpp_jid == "" || !user.notify_about?(issue)
                next
            end
            Bot.deliver user.xmpp_jid, message
        end
    end

end
