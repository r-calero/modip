module ApplicationHelper

	def delete_dialog(id, url, text = "Destroy", ok_text = "Delete", cancel_text = "Cancel", method = :post, header = "Delete a resource", body = "Are you sure?")
	    
	  #<!-- Button to trigger modal -->
	  link = link_to(text, "##{id}", "data-toggle" => "modal")
	  
	  close_button = content_tag(:a, content_tag(:span, 'x', {:class => "badge badge-important"}), {:class => "close",  "data-dismiss" => "modal"})
	  header = content_tag(:h3, header, {:id => "#{id}Label"})
	  modal_head = content_tag(:div, close_button.concat(header), {:class => "modal-header"})
	  modal_body = content_tag(:div, content_tag(:p, body, {}), {:class => "modal-body"})
	  modal_footer = content_tag(:div, link_to(cancel_text, "#", {"data-dismiss" => "modal", :class => "btn"}).concat(link_to(ok_text, url, :method => :delete, :class => 'btn btn-danger')), 
	  	{:class => "modal-footer"})
	  modal = content_tag(:div, modal_head.concat(modal_body).concat(modal_footer), {:id => id, :class => "modal hide fade", :tabindex => "-1", :role => "dialog", "aria-labelledby" =>"#{id}Label", "aria-hidden" =>"true"})		
	  
	  #<!-- Modal -->
	  link.concat(modal)
	end
	
	def sortable(column, sort_column, sort_direction, title = nil)
		title ||= column.titleize
		direction = column == sort_column && sort_direction == "desc" ? "asc" : "desc"
		link_to title, params.merge(:sort => column, :direction => direction), {:class => "current #{sort_direction}"}
	end

end
