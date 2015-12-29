class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :image, null: "default-0.png", default: "default-0.png"

      t.timestamps null: false
    end
  end
end
