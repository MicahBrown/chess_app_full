class Game < ApplicationRecord
  has_many :pieces

  def create_with_pieces!
    build_all_pieces
    save!
  end

  def build_all_pieces
    Piece::TYPES.each do |type|
      klass = "Piece::#{type}".constantize
      klass.colors.each do |color, val|
        klass::START_POS[color].each do |pos|
          self.pieces.build(type: klass, color: color, position: pos)
        end
      end
    end

    true
  end
end
