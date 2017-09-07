class XmppNotificationRenderer
  def initialize(context, user)
    @view = XmppNotificationView.new(context, user)
  end

  def render_issue
    view.render(file: "xmpp/issue_add.text.erb")
  end

  def render_journal
    view.render(file: "xmpp/issue_edit.text.erb")
  end

  private

  attr_reader :view

  class XmppNotificationView < ActionView::Base
    include Redmine::I18n
    include IssuesHelper
    include CustomFieldsHelper

    attr_reader :issue, :journal, :user

    def initialize(context, user)
      @issue = context[:issue]
      @journal = context[:journal]
      @user = user
      super(ActionController::Base.view_paths)
    end

    def redmine_url
      "#{Setting[:protocol]}://#{Setting[:host_name]}"
    end

    def journal_details
      journal.visible_details(user) if journal
    end

    def render(*)
      I18n.with_locale(locale) do
        eliminate_multiple_blank_lines(super)
      end
    end

    def eliminate_multiple_blank_lines(text)
      text.gsub(/^$\n+/, "\n").strip
    end

    def locale
      user.language.presence || I18n.default_locale
    end
  end
end
