class AddThreadMembershipHead < ActiveRecord::Migration
  def change
    add_reference :thread_memberships, :head, references: :messages, index: true
    add_foreign_key :thread_memberships, :messages, column: :head_id
  end
end
