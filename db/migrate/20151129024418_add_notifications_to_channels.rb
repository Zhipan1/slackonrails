class AddNotificationsToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :notification, :boolean, default: false
  end
end
