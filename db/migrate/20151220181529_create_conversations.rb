class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.references :channel, index: true
      t.references :message_thread, index: true

      t.timestamps null: false
    end
    add_foreign_key :conversations, :channels
    add_foreign_key :conversations, :message_threads
  end
end
