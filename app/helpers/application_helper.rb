module ApplicationHelper

  def label_with_tooltip(title, text, link=nil)
    lambda do |label, required, explicit_label|
      start = "#{label} <i class='help large fitted circle icon teal link'
                          data-offset='-12'
                          data-variation='wide inverted'
                          data-html='<div class=\"header\">#{title}</div>
                                     <div class=\"content\">#{text}</div>"
      link ? start + "<a href=\"#{link}\" target=\"blank\">More help</a>'></i>" : start + "'></i>"
    end
  end

end
