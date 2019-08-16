class Game < ApplicationRecord
  enum turn: [:white_turn, :black_turn]
  has_many :pieces

  def current_turn_color
    white_turn? ? :white : :black
  end

  def create_with_pieces!
    build_all_pieces
    save!
  end

  def flip_turn!
    self.turn = white_turn? ? :black_turn : :white_turn
    self.save!
  end

  def build_all_pieces
    Piece::TYPES.each do |type|
      klass = "Piece::#{type}".constantize
      klass.teams.each do |team, val|
        klass::START_POS[team].each do |pos|
          self.pieces.build(type: klass, team: team, position: pos)
        end
      end
    end

    true
  end
end
