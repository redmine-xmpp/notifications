class User < Principal
  has_one :xmpp_setting, :dependent => :destroy, :class_name => "XmppNotificationsUserSetting"

  def xmpp_jid
    return "" unless self.xmpp_setting
    return self.xmpp_setting.jid
  end

  def xmpp_jid=(jid)
    self.xmpp_setting = XmppNotificationsUserSetting.new unless self.xmpp_setting
    self.xmpp_setting.jid = jid
    self.xmpp_setting.save!
  end
end
