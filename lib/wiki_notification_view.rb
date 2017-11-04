class WikiNotificationView < XmppNotificationView
  def initialize(context, user)
    populate_template_variables(context[:page])
    super
  end

  def populate_template_variables(page)
    @wiki_content = page.content
    @wiki_content_url = url_for(controller: "wiki",
                                action:     "show",
                                project_id: @wiki_content.project,
                                id:         page.title)
    @wiki_diff_url = url_for(controller: "wiki",
                             action:     "diff",
                             project_id: @wiki_content.project,
                             id:         page.title,
                             version:    @wiki_content.version)
  end

  def render
    super(file: "mailer/wiki_content_updated.text.erb")
  end
end