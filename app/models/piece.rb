class Piece < ApplicationRecord
  enum color: %w[white black]

  TYPES = %w[King Queen Bishop Knight Rook Pawn].freeze

  belongs_to :game

  validates :color, presence: true

  def type_name
    self.type.split("::").last.downcase
  end
end
