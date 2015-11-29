class PublicChannel < Channel
  validates :name, presence: true, uniqueness: true
end
