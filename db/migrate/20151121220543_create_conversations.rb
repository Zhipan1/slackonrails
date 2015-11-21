class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.references :user, index: true
      t.references :channel, index: true

      t.timestamps null: false
    end
    add_foreign_key :conversations, :users
    add_foreign_key :conversations, :channels
  end
end
