class WikiUpdatedNotifier
  include Sidekiq::Worker
  include XmppNotificationSender

  def perform(page_id)
    updated_wiki(page: WikiPage.find(page_id))
  end
end