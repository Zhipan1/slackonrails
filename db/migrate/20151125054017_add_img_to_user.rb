class AddImgToUser < ActiveRecord::Migration
  def change
    add_column :users, :image, :string, default: 'drake.jpg'
  end
end
