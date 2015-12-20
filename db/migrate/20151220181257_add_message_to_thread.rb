class AddMessageToThread < ActiveRecord::Migration
  def change
    add_reference :messages, :message_thread, index: true
  end
end
