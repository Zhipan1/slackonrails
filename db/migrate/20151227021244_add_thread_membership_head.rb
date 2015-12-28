class AddThreadMembershipHead < ActiveRecord::Migration
  def change
    add_reference :thread_memberships, :head, references: :message_threads, index: true
    add_foreign_key :thread_memberships, :message_threads, column: :head_id
  end
end
