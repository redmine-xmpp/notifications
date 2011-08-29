class XmppNotificationsMyAccountHooks < Redmine::Hook::ViewListener
  def view_my_account(context={})
    user = context[:user]
    f = context[:form]
    return "" unless user
    res = ""
    res << "<hr /><p>"
    res << f.text_field(:xmpp_jid, :label => :xmpp_label_jid)
    res << "</p>"
    return res
  end
end