class AddTypeToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :type, :string, default: "Channel"
  end
end
