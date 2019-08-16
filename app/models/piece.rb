class Piece < ApplicationRecord
  include TeamEnum

  serialize :moves, Array

  TYPES = %w[King Queen Bishop Knight Rook Pawn].freeze

  belongs_to :game, autosave: true
  has_many :game_moves

  validates :team, presence: true

  def type_name
    self.type.split("::").last.downcase
  end

  def move!(position)
    self.game_moves.build(game: game, team: team, move: position)
    self.position = position
    self.save!
  end
end
