class AddOriginChannelToMessage < ActiveRecord::Migration
  def change
    add_reference :messages, :origin, references: :channels, index: true
    add_foreign_key :messages, :channels, column: :origin_id
  end
end
