class MessageNotifier
  include Sidekiq::Worker
  include XmppNotificationSender

  def perform(message_id)
    message(message: Message.find(message_id))
  end
end