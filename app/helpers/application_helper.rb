module ApplicationHelper
  def piece(name, white=false)
    content_tag :span, nil, class: "piece #{name} #{white ? 'white' : 'black'}"
  end
end
