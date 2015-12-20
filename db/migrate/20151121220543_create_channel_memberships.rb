class CreateChannelMemberships < ActiveRecord::Migration
  def change
    create_table :channel_memberships do |t|
      t.references :user, index: true
      t.references :channel, index: true

      t.timestamps null: false
    end
    add_foreign_key :channel_memberships, :users
    add_foreign_key :channel_memberships, :channels
  end
end
