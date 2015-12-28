class AddChannelThreadToChannel < ActiveRecord::Migration
  def change
    add_reference :channels, :main_thread, references: :message_threads, index: true
    add_foreign_key :channels, :message_threads, column: :main_thread_id
  end
end
