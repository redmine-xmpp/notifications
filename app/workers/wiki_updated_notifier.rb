class WikiUpdatedNotifier
  include Sidekiq::Worker
  include XmppNotificationSender

  def perform(page_id, author_id)
    updated_wiki(page: WikiPage.find(page_id), author: User.find_by_id(author_id))
  end
end