class XmppNotificationsMyAccountHooks < Redmine::Hook::ViewListener
  def xmpp_user_text_field(context={})
    user = context[:user]
    f = context[:form]
    return "" unless user
    res = ""
    res << "<hr /><p>"
    res << f.text_field(:xmpp_jid, :label => :xmpp_label_jid)
    res << "</p>"
    return res
  end

  alias_method :view_my_account, :xmpp_user_text_field
  alias_method :view_users_form, :xmpp_user_text_field
end