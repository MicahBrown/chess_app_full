module ApplicationHelper
  def piece(p)
    type = p.type_name
    color = p.color
    content_tag :span, image_tag("#{color}_#{type}.svg"), class: "piece", data: {color: color, type: type}
  end
end
