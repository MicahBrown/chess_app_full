class Piece < ApplicationRecord
  include TeamEnum

  serialize :moves, Array

  scope :uncaptured, -> { where(captured: false) }

  TYPES = %w[King Queen Bishop Knight Rook Pawn].freeze

  belongs_to :game, autosave: true
  has_many :game_moves

  validates :team, presence: true

  def type_name
    self.type.split("::").last.downcase
  end

  def capture!
    self.captured = true
    self.save!
  end

  def move!(position)
    self.class.transaction do
      self.game_moves.build(game: game, team: team, move: position)
      self.position = position
      self.game.pieces.where(position: position).where.not(id: self.id).uncaptured.first&.capture!
      self.save!
    end
  end
end
