class AddTypeToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :type, :string, default: "PublicChannel"
  end
end
