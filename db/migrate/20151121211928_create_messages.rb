class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text
      t.references :channel, index: true

      t.timestamps null: false
    end
  end
end
