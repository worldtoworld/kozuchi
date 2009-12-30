module DealsHelper

  def deal_tab(caption, url, current_caption, html_options = {})
    content_tag :div, :class => current_caption == caption ? "selectedtab" : "tab" do
      if current_caption == caption
        caption
      else
        link_to_remote caption, {:update => "deal_forms", :url => url, :method => :get, :before => "if($('notice')){ $('notice').hide();}"}, html_options
      end
    end
  end

  def deal_form(current_caption, options = {})
    concat("<div id='tabwindow'>")
    concat(render :partial => 'deal_tabs', :locals => {:deal => @deal, :current_caption => current_caption})
    concat("<div id='tabsheet' class='tabsheet'>")
    merged_before = "$('deal_year').value = $('date_year').value; $('deal_month').value = $('date_month').value; $('deal_day').value = $('date_day').value;"
    merged_before << options.delete(:before) if options[:before]
    remote_form_for :deal, @deal, {:before => merged_before}.merge(options) do |f|
      concat(f.hidden_field :year)
      concat(f.hidden_field :month)
      concat(f.hidden_field :day)
      yield f
    end
    concat("</div>")
    concat("</div>")
  end

  def datebox
    content_tag :div, :id => "datebox" do
      content_tag :form, :id => "datebox_form" do
        text_field(:date, :year, :size => 4, :max_length => 4, :tabindex => 1) +
          text_field(:date, :month, :size => 2, :max_length => 2, :tabindex => 2) +
          text_field(:date, :day, :size => 2, :max_length => 2, :tabindex => 3)
      end
    end
  end

end
