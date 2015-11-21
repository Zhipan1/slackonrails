class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :message, index: true
      t.string :name

      t.timestamps null: false
    end
    add_foreign_key :users, :messages
  end
end
