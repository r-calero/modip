module CompoundsHelper

  def format_molecular_formula(formula)
    compounds = formula.scan(/\D+/)
    atoms = formula.scan(/\d+/)
    for i in (0 .. compounds.size - 1)
      yield compounds[i]
      yield content_tag(:sub, i < atoms.size ? atoms[i]: "", :class => "atom-formula")
    end
    nil
  end
  
  def compound_docking(cid, cancel_text = "Cancel")
	if(user_id = session[:user_id])
	 #<!-- Button to trigger modal -->
	 link = link_to('Docking', "##{cid}", "data-toggle" => "modal", :class => "btn btn-primary")
	 
	 close_button = content_tag(:a, content_tag(:span, 'x', {:class => "badge badge-important"}), {:class => "close",  "data-dismiss" => "modal"})
	 header = content_tag(:h3, 'Make Docking', {:id => "#{cid}Label"})
	 modal_head = content_tag(:div, close_button.concat(header), {:class => "modal-header"})
	 form = form_tag(start_docking_user_path(:id => user_id)) do 
  		 compound = hidden_field_tag :cids, "pages:;cids:#{cid}"
         targets = collection_select(:target, :target_id, Target.all, :id, :name)
         modal_footer = content_tag(:div, link_to(cancel_text, "#", {"data-dismiss" => "modal", :class => "btn"}).concat(submit_tag :Ok , :class => 'btn btn-primary'), {:class => "modal-footer"})
         compound.concat(targets).concat(modal_footer)
     end
	 modal_body = content_tag(:div, form, {:class => "modal-body"})
	 modal = content_tag(:div, modal_head.concat(modal_body), {:id => cid, :class => "modal hide fade", :tabindex => "-1", :role => "dialog", "aria-labelledby" =>"#{cid}Label", "aria-hidden" =>"true"})		
	  
	  #<!-- Modal -->
	  link.concat(modal)
	end
  end

end
