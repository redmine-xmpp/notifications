class MessageNotificationView < XmppNotificationView
  def initialize(context, user)
    populate_template_varialbes(context[:message])
    super
  end

  def populate_template_varialbes(message)
    @message = message
    @message_url = url_for(message.event_url)
  end

  def render
    super(file: "mailer/message_posted.text.erb")
  end
end