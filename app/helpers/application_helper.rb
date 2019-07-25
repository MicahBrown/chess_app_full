  module ApplicationHelper
  def piece(p)
    type = p.type_name
    color = p.team
    content_tag :span, image_tag("#{color}_#{type}.svg"), class: "piece", data: {color: color, type: type, update_path: game_piece_moves_path(p.game_id, p)}
  end
end
