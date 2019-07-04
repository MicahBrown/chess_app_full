class Piece < ApplicationRecord
  enum team: %w[white black]

  serialize :moves, Array

  TYPES = %w[King Queen Bishop Knight Rook Pawn].freeze

  belongs_to :game

  validates :team, presence: true

  def type_name
    self.type.split("::").last.downcase
  end
end
