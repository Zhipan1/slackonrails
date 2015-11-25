class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :topic
      t.string :name

      t.timestamps null: false
    end
    add_foreign_key :channels, :users, column: :user_id
    add_foreign_key :channels, :messages
  end
end
