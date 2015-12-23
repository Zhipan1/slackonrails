class CreateThreadMemberships < ActiveRecord::Migration
  def change
    create_table :thread_memberships do |t|
      t.references :message_thread, index: true
      t.references :channel, index: true
      t.references :message, index: true

      t.timestamps null: false
    end
    add_foreign_key :thread_memberships, :message_threads
    add_foreign_key :thread_memberships, :channels
    add_foreign_key :thread_memberships, :messages
  end
end
