# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def menu_link_to(text, url_options = {}, html_options = {})
    if current_page?(url_options)
      html_options[:class] = 'active'
    end
    link_to(text, url_options, html_options)
  end
  
  def use_openid_link(text = 'Use OpenID')
    %{<a class="useOpenid" href="#">#{h text}</a>}
  end
  
  def use_password_link(text = 'Use Password')
    %{<a class="usePassword" href="#">#{h text}</a>}
  end
  
  def humanize_plan(plan)
    price = Money.new(plan[:price], plan[:currency])
    price.format + '/month'
  end
end
