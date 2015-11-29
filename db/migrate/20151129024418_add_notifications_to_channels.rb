class AddNotificationsToChannels < ActiveRecord::Migration
  def change
    add_column :conversations, :notification, :boolean, default: false
  end
end
