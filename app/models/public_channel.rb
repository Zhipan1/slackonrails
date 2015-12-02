class PublicChannel < Channel
  validates :name, uniqueness: true, presence: true, allow_blank: false
end
