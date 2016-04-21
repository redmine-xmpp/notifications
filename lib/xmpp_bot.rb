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
        def_delegators :instance, :deliver, :setup
    end

    def ping
        # pong
    end

    def comment issue, message
        ap "ASKED TO COMMENT"
        ap issue
        ap message
    end

    def initialize
        ap "bot init"
        @config = Setting.plugin_redmine_xmpp_notifications

        @jabber_id = @config["jid"]
        @jabber_password = @config["jidpassword"] or ENV['jabber_password'] or ''

        @static_config = {
            %r{^c([[:digit:]]+)[[:space:]]+(.+)$} => Proc.new do |issue, message|
                comment(issue, message)
            end
        }

        ap "===================================== Creating bot ============================"
        connect
    end

    def connect
        ap "bot connect"
        ap @client
        return unless @client.nil?
        ap "has to create client"
        jid = JID.new(@jabber_id)
        @client = Client.new jid
        @client.connect
        @client.auth @jabber_password
        @client.send(Presence.new.set_type(:available))
        puts "Hurray...!!  Connected..!!"

        @client.add_message_callback do |message|
            ap "="*20 + " Received message " + "="*20
            ap message

            unless message.body.nil? && message.type != :error
                body = message.body
                puts "Received message: #{message.body}"
                #Echo the received message back to the sender.
                # reply = Message.new(message.from, message.body)
                # reply.type = message.type
                # @client.send(reply)

                @static_config.each do |rx, block|
                    if m = rx.match(body)
                        block.call(*m.captures)
                    else
                        deliver message.from, "What are you talking about?"
                    end
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
