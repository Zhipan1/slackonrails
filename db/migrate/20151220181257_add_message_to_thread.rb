class AddMessageToThread < ActiveRecord::Migration
  def change
    add_reference :messages, :message_thread, index: true
    add_foreign_key :messages, :message_threads
  end
end
