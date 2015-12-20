class CreateConversationParticipants < ActiveRecord::Migration
  def change
    create_table :conversation_participants do |t|
      t.references :user, index: true
      t.references :message_thread, index: true

      t.timestamps null: false
    end
    add_foreign_key :conversation_participants, :users
    add_foreign_key :conversation_participants, :message_threads
  end
end
