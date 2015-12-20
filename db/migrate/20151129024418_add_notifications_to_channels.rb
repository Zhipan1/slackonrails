class AddNotificationsToChannels < ActiveRecord::Migration
  def change
    add_column :channel_memberships, :notification, :boolean, default: false
  end
end
