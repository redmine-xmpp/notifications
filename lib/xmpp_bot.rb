require 'xmpp4r'
require 'xmpp4r/client'
require 'forwardable'
require 'singleton'

class Bot
    include Jabber
    include Singleton

    attr_reader :client

    class << self
        extend Forwardable
        def_delegators :instance, :deliver, :ping
    end

    def ping
        # pong
    end

    def jid_user fulljid
        jid = Jabber::JID.new(fulljid)
        # TODO: check if multiple users have the same jid
        XmppNotificationsUserSetting.where(jid: jid.strip.to_s).first.user
    end

    ###################################
    # COMMENT
    ###################################
    def add_comment original_message, issue, comment
        # jid = Jabber::JID.new(original_message.from)
        # # TODO: check if multiple users have the same jid
        # user = XmppNotificationsUserSetting.where(jid: jid.strip.to_s).first.user
        user = jid_user original_message.from
        iss = Issue.find(issue)


        if user.allowed_to?(:edit_issues, iss.project)
            iss.journals.create notes: comment
            deliver original_message.from, "Added new comment to issue: " + iss.subject
        else
            deliver original_message.from, "Sorry! You've no rights to comment that issue"
        end
    rescue ActiveRecord::RecordNotFound => e
        deliver original_message.from, "ERROR: unknown issue"
    end

    ###################################
    # SET STATE
    ###################################
    def set_state original_message, issue, state
        iss = Issue.find(issue)

        deliver original_message.from, "ERROR: Not implemented yet"
    rescue ActiveRecord::RecordNotFound => e
        deliver original_message.from, "ERROR: unknown issue"
    end

    def select_matching klass, value, match_fields, equal_fields
        t = klass.arel_table
        preql = t[:id].eq(0)
        match_fields.each do |field|
            preql = preql.or(t[field].matches("%#{value}%"))
        end
        equal_fields.each do |field|
            preql = preql.or(t[field].eq(value))
        end
        klass.where(preql)
    end
    ###################################
    # CREATE NEW ISSUE
    ###################################
    def create_new_issue original_message, message
        # iss = Issue.find(issue)
        rmentions = %r{(?'project'\+(?:\w+|"[\w\s]+"))|(?'assigned'\!\w+)|(?'watcher'\@\w+)}
        user = jid_user original_message.from

        mentions = Hash.new([].freeze)
        match_all(message, rmentions).each do |match|
            match.names.each do |name|
                mentions[name] += [match[name]] unless match[name].nil?
            end
        end

        subject = message.gsub(rmentions, '').strip

        ##### GETTING PROJECT
        if mentions["project"].length.zero?
            deliver original_message.from, "ERROR: No project specified!"
            return
        end

        project = mentions["project"][0].gsub(/(^[\+"]*|["]*$)/, '')

        if mentions['project'].length>1
            deliver original_message.from, "WARNING: Several projects specified - using <#{project}>"
        end

        # t = Project.arel_table
        # projects = Project.where(t[:name].matches("%#{project}%").or(t[:identifier].eq(project)))
        projects = select_matching Project, project, [:name], [:identifier]
        if projects.length>1
            deliver original_message.from, "ERROR: Multiple projects match your criteria - provide more specific project name or id"
            return
        end
        project = projects[0]
        ##### /GETTING PROJECT

        assigned = []
        mentions['assigned'].map { |e| e.gsub(/^\!/, '') }.each do |uname|
            tmp = select_matching User, uname, [], [:login, :mail]
            assigned += tmp
        end

        watchers = []
        mentions['watcher'].map { |e| e.gsub(/^\@/, '') }.each do |uname|
            tmp = select_matching User, uname, [], [:login, :mail]
            watchers += tmp
        end

        unless user.allowed_to?(:add_issues, project)
            deliver original_message.from, "ERROR: Sorry! You've no rights to create issues"
            return
        end

        issue = Issue.new(author: user, project: project)
        issue.subject = subject
        if assigned.length.zero?
            issue.assigned_to = user
        else
            issue.assigned_to = assigned[0]
        end
        watchers.each do |watcher|
            issue.add_watcher(watcher)
        end
        issue.tracker_id = 1
        if issue.save
            deliver original_message.from, "Successfuly created new issue with id: #{issue.id}"
        else
            deliver original_message.from, "ERROR: Something went wrong while creating new issue"
        end



        # deliver original_message.from, assigned.inspect
        # deliver original_message.from, watchers.inspect
        # deliver original_message.from, mentions.inspect
        # deliver original_message.from, "ERROR: Not implemented yet"
    rescue ActiveRecord::RecordNotFound => e
        deliver original_message.from, "ERROR: unknown issue"
    end

    def match_all(match_str, regex)
        # match_str = self
        match_datas = []
        while match_str.length > 0 do
            md = match_str.match(regex)
            break unless md
            match_datas << md
            match_str = md.post_match
        end
        return match_datas
    end

    def initialize
        @config = Setting.plugin_redmine_xmpp_notifications

        @jabber_id = @config["jid"]
        @jabber_password = @config["jidpassword"] or ENV['jabber_password'] or ''

        @static_config = {
            %r{^\+#([[:digit:]]+)[[:space:]]+(.+)$} => Proc.new do |original_message, issue, comment_message|
                add_comment(original_message, issue, comment_message)
            end,
            %r{^\.#([[:digit:]]+)[[:space:]]+(.+)$} => Proc.new do |original_message, issue, state|
                set_state(original_message, issue, state)
            end,
            %r{^\!#[[:space:]]+(.+)$} => Proc.new do |original_message, message|
                create_new_issue(original_message, message)
            end,
        }

        connect
    end

    def connect
        return unless @client.nil?

        jid = JID.new(@jabber_id)
        @client = Client.new jid
        @client.connect
        @client.auth @jabber_password
        @client.send(Presence.new.set_type(:available))

        @client.add_message_callback do |message|
            unless message.body.nil? && message.type != :error
                body = message.body

                if @static_config.map { |rx, block| if m=rx.match(body) then block.call(message, *m.captures); 1 end }.reject(&:nil?).empty? then
                    deliver message.from, "What are you talking about?"
                end

            end
        end
    end

    def deliver jid, message, message_type = :chat
        message = Message.new(jid, message)
        message.type = message_type
        @client.send(message)
    end
end
