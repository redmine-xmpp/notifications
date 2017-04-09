class CreateXmppNotificationsUserSettings < ActiveRecord::Migration
  def self.up
    create_table :xmpp_notifications_user_settings do |t|
      t.column :user_id, :integer
      t.column :jid, :string
      t.column :updated_at, :timestamp
    end
  end
  
  def self.down
    drop_table :xmpp_notifications_user_settings
  end
end
