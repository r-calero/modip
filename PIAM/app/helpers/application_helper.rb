module ApplicationHelper

  # <li> of the top navigation bar, marked active on its own pages.
  def nav_item(label, path, active)
    content_tag(:li, link_to(label, path), :class => (active ? 'active' : nil))
  end

  # Page title: "Section - MODIP" (set with content_for :title).
  def page_title
    content_for?(:title) ? "#{content_for(:title)} - MODIP" : "MODIP - Molecular Docking Integrated Platform"
  end

  # 2D depiction of a compound, served by PubChem.
  def structure_image(cid, size = 200)
    image_tag("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{cid.to_i}/PNG?image_size=#{size.to_i}x#{size.to_i}",
              :alt => "2D structure of CID #{cid}", :width => size, :height => size, :class => 'img-polaroid structure-image')
  end

  # Delete link confirmed with the shared modal (confirm_modal.js).
  def delete_dialog(id, url, text = "Destroy", ok_text = "Delete", cancel_text = "Cancel", method = :post, header = "Delete a resource", body = "Are you sure?")
    link_to(text, url, :method => :delete, :confirm => body, :class => 'delete-link',
            'data-confirm-title' => header, 'data-confirm-ok' => ok_text)
  end

  # Options for a link or button confirmed with the shared modal.
  def confirm_options(message, title, ok, style = 'danger')
    { :confirm => message, 'data-confirm-title' => title, 'data-confirm-ok' => ok, 'data-confirm-style' => style }
  end

	def sortable(column, sort_column, sort_direction, title = nil)
		title ||= column.titleize
		direction = column == sort_column && sort_direction == "desc" ? "asc" : "desc"
		link_to title, params.merge(:sort => column, :direction => direction), {:class => "current #{sort_direction}"}
	end

end
