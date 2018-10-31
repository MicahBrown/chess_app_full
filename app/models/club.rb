class Club < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :club_memberships
  has_many :users, through: :club_memberships

  before_create :set_uid

  def set_uid
    self.uid = loop do
      token =  SecureRandom.base58(5)
      break token unless Club.where("LOWER(uid) = ?", token.downcase).exists?
    end
  end
end
