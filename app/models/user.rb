class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :name, presence: true, uniqueness: true
  belongs_to :message
  has_many :messages
  has_many :conversation_participants
  has_many :message_threads, through: :conversation_participants
  has_many :channel_memberships
  has_many :channels, through: :channel_memberships
  delegate :direct_messages, :public_channels, to: :channels
end
