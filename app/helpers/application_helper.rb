module ApplicationHelper
  def piece(name, white=false)
    color = white ? 'white' : 'black'
    content_tag :span, image_tag("#{color}_#{name}.svg"), class: "piece", data: {color: color, type: name}
  end
end
