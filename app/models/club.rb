class Club < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :club_memberships
  has_many :users, through: :club_memberships
end
