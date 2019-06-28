class Piece::Pawn < Piece
  START_POS = { "white" => %w[A2 B2 C2 D2 E2 F2 G2 H2],
                "black" => %w[A7 B7 C7 D7 E7 F7 G7 H7] }.freeze
end