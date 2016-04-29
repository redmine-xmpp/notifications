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

    ###################################
    # COMMENT
    ###################################
    def add_comment original_message, issue, comment
        jid = Jabber::JID.new(original_message.from)
        # TODO: check if multiple users have the same jid
        user = XmppNotificationsUserSetting.where(jid: jid.strip.to_s).first.user
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
