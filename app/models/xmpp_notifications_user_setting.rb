class XmppNotificationsUserSetting < ActiveRecord::Base
  unloadable
  belongs_to :user
  validates_presence_of :user
  
  SYSTEM_SETTING = "__system_setting__"
  
  def self.find_settings_by_user_id(user_id)
    XmppNotificationsUserSetting.find :first, :conditions => ["user_id=?", user_id]
  end
end