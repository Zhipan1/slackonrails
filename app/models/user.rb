class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :message
  has_many :messages
  has_many :conversations
  has_many :channels, through: :conversations
  delegate :direct_messages, :public_channels, to: :channels
end
