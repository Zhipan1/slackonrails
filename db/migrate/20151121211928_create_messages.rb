class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text, null: "", default: ""

      t.timestamps null: false
    end
  end
end
