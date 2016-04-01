var compound_selected = {};
var current_page = 1;
compound_selected[current_page] = [];
var page_selected = {};
var select_all = false;
var total = 0;
var page_size = 0;
var remainder = 0;
var pages = 0;

$(document).ready(function(){
	total = $("#select").attr("total");
    page_size = $("#select").attr("page");
    remainder = total % page_size;
    pages =  (total / page_size).toFixed();
    if(remainder > 0){
		pages ++;
	}
	for(var i = 1; i <= pages; i++){
		page_selected[i] = false;
	}
  
  $("form").submit(function() {
  	var hidden =  $(this).find('#cids');
  	var result = "";
  	if(select_all){
		hidden.attr('value', 'all');
	}
	else{
		result = "pages:";
		var pages = "";
		$.each(page_selected, function(index, value){
			if(page_selected[index]){
				pages += index + ":";
			}
		});
		if(pages != ""){
			pages = pages.substring(0, pages.length - 1);
		}
		result += pages + ";cids:"
		$.each(compound_selected, function(index, page_array){
			if(page_array.length > 0 && !page_selected[index]){
				result += make_list(page_array) + ":"
			}
		});
		hidden.attr('value', result.substring(0, result.length - 1));
   }
   });
});

function insert_in_selection(cid){
	var td1 = $("<td></td>");
  var td2 = $("<td></td>").addClass(cid);
  var checkbox = $("<input>").attr('id', cid).attr('type', "checkbox").attr('checked', true).attr('disabled', 'disabled');
  td1.append(checkbox);
  td2.text(cid);
  
	var last_row = $("#selection tbody tr:last");
	if (last_row.children().length < 10){
		var tr = $("#selection tbody tr:last");
		tr.append(td1);
  	tr.append(td2);
	}
	else{		
		var tr = $("<tr></tr>");
		tr.append(td1);
  	tr.append(td2);
		$("#selection tbody").append(tr);
	}
  
}

function remove_from_selection(cid){
	var table = $("#selection");
	var checkbox = table.find("#" + cid);
	var last_checkbox = $("#selection tbody tr td input:last");
	var last_row = $("#selection tbody tr:last");
	var last_column = $("#selection tbody tr td:last");
	if (checkbox.attr('id') != last_checkbox.attr('id')){
		var checkbox_column = table.find("." + cid);
		checkbox_column.text(last_column.text());
		checkbox.removeClass();
		checkbox.addClass(last_column.attr('class'));
	}
	if(last_row.children().length > 2){
		//eliminar el valor de las ultimas 2 columna
		last_column.remove(); 
		$("#selection tbody tr td:last").remove();
	}
	else{
		last_row.remove();
	}
}

$(".checkbox").live("click",function(){
    if(compound_selected[current_page] == undefined){
        compound_selected[current_page] = []
    }
    var all = $(".all:checkbox");
    var per_page = $(".per-page:checkbox");
    var obj = $(this);
    var cid = obj.attr('id');
    if(obj.is(':checked')){
        compound_selected[current_page].push(cid);
        // selecionados todos los compuestos de la pagina;
        if(compound_selected[current_page].length == $("#select tbody tr td input:checkbox").length){
        	per_page.attr('checked', true);
        	page_selected[current_page] = true;
        	if(all_page_selected()){
				select_all = true;
				all.attr('checked', true);
			}
        }
    }
    else{
        if(per_page.is(':checked')){
        	per_page.attr('checked', false);
        	page_selected[current_page] = false;
        }
        if(all.is(':checked')){
        	all.attr('checked', false);
        	select_all = false;
        } 
        var page_array = compound_selected[current_page];
        var indexOf = $.inArray(cid, page_array);
        //elemina el elemento del array de la pagina actual;
        compound_selected[current_page].splice(indexOf, 1);
    }
});

$(".per-page:checkbox").live("click", function(){
	if(compound_selected[current_page] == undefined){
        compound_selected[current_page] = []
    }
    var obj = $(this);
    $("#select tbody tr td input:checkbox").attr('checked', obj.is(':checked'));
    var page_array = compound_selected[current_page];
    if(obj.is(':checked')){
		page_selected[current_page] = true;
        var inputs = $("#select tbody tr td input:checkbox");     
        for(var i = 0; i < inputs.length; i++){
            var input = inputs[i];
            var cid = input.getAttribute('id');
            if($.inArray(cid, page_array) == -1){
                page_array.push(cid);
            }
        }
        if(all_page_selected()){
			select_all = true;
			$(".all:checkbox").attr('checked', true);
		}
    }
    else{
        var all = $(".all:checkbox");
        if(all.is(':checked')){
        	all.attr('checked', false)
        }
        select_all = false;
        page_selected[current_page] = false;
        compound_selected[current_page] = [];
    }
});

$(".all:checkbox").live("click", function(){
	var obj = $(this);
	if(obj.is(':checked')){
		select_all = true;
	    /*$("#select").addClass('spinner');
	    $.getJSON("/users/"+ $("#cids").attr('user') + "/docking.json", function(data) {
			$.each(data, function(key, values){
			   var index = parseInt(key);
			   compound_selected[index] = values;
			   page_selected[index] = true;
			});
			$("#select tbody tr td input:checkbox").attr('checked', true);
			$(".per-page:checkbox").attr('checked', true);
			$("#selection tbody tr").remove();
			$("#selection tbody").append($("<tr></tr>"));
	     	$("#select").removeClass("spinner");
	   });*/
	    for(var i = 1; i <= pages; i++){
			page_selected[i] = true;
		}
	    
	}
	else{
	  select_all = false;
	  page_selected = {};
	  $("#select tbody tr td input:checkbox").attr('checked', false);
	  $(".per-page:checkbox").attr('checked', false);
	  $.each(compound_selected, function(key, values){
	  	compound_selected[key] = []
	  });
	}
});

$('.pagination ul li a').live("click",function(){
        var obj = $(this);
        var href = obj.attr('href');
        
		// determina la pagina actual;
        var page_num = href.match(/page=\d+/);
        if(page_num != undefined){
        	current_page = parseInt(page_num.toString().match(/\d+/));       
        }
        else{
        	current_page = 1;
        }
        if(page_selected[current_page]){
			$("#selected").attr('page-cids', "all");
		}
		else{
        //crea una lista de los cids separados por :;
			var cids = make_list(compound_selected[current_page]);
			$("#selected").attr('page-cids', cids);
		}
        obj.addClass("selected");
       
});

function all_page_selected(){
     for(var i = 1; i <= pages; i++){
		if(!page_selected[i]){
			return false;
		}
	}
	return true;
}

function make_list(page_array) {
    var result = "";
    if(page_array != undefined){
     for(var i = 0; i < page_array.length; i++){
        result += page_array[i] + ":" ;
        
     }
     return result.substring(0, result.length - 1)
    }
    else{
     return result
    }
}

var TABLE = {};
TABLE.paginate = function(table, pageLength) {
	// 1. Set up paging information
	var $table = $(table);
	var $rows = [];
	$.each(compound_selected, function(index, values){
		for(var i in values){
			$rows.push(values[i]);
		}
	});
	var numPages = Math.ceil($rows.length / (5 * pageLength)) - 1;
	var current = 0;
	// 2. Set up the navigation controls
	var $nav = $('.table-wrapper').find('.pager');
	var $back = $nav.find('li:first-child');
	var $next = $nav.find('li:last-child');
	//$nav.find('a.paging-this b').text(current + 1);
	//$nav.find('a.paging-this span').text(numPages + 1);
	$back.addClass('disabled').click(function() {
		pagination('<');
	});
	if(numPages <= 0){
		$next.addClass('disabled')
	}
	else{
		$next.removeClass('disabled').click(function() {
			pagination('>');
		});
	}
		
	populate_table = function(index){
		$table.find('tbody > tr').remove();
		$table.find('tbody').append("<tr></tr>");
		var end = Math.min(index + (5 * pageLength), $rows.length);
		var current = $rows.slice(index, end);
		//alert(current.length + " start: " + index + " end: " + end);
		for(var i in current){
			insert_in_selection(current[i]);
		}	
	}
	
	// 3. Show initial rows
	populate_table(0);
	
	pagination = function (direction) {
			// 5. Reveal the correct rows
		  reveal = function (current) {
				$back.removeClass("disabled");
				$next.removeClass("disabled");
				populate_table(current * pageLength * 5);
				//$nav.find("a.paging-this b").text(current + 1);
			}
		// 4. Move previous and next 
		if (direction == "<") { // previous
			if (current > 1) {
				reveal(current -= 1);
			}
			else if (current == 1) {
				reveal(current -= 1);
				$back.addClass("disabled");
			}
		} 
		else { // next
			if (current < numPages - 1) {
				reveal(current += 1);
			}
			else if (current == numPages - 1) {
				reveal(current += 1);
				$next.addClass("disabled");
			}
		}
 	}
};

$(document).ready(function(){
    $('#info-nav a:first').tab('show');
    $('#info-nav a').click(function (e) {
        e.preventDefault();
        /*var result = "";
        $.each(compound_selected, function(index, page_array){
          result += make_list(page_array) + ":"
	      });
        if($(this).attr('id') == "selected"){
        	 $.ajax({
        		type: 'POST',
        		url: 'docking/compounds/selected',
        		data: {cids: result.substring(0, result.length - 1)}
        	});
        
        }*/
        if($(this).attr('id') == "selected"){
        	TABLE.paginate("#selection", 10);
        }
        $(this).tab('show');
    });
});



/*----------------------------------------- user notification -------------------------------------------------*/

var source = null;
var compound_progress = 0;
var compound_total = 0;

function start_docking_service(dir, progress, total){
    compound_progress = parseInt(progress);
    compound_total = total;

    source = new EventSource(dir);
    source.addEventListener("CompoundProcessed", compound_process, false);
    source.addEventListener("Finished", finished, false);
    source.addEventListener("Stop", stop, false);
    update_page(0);
}


function stop(event){
	finished(event)
}

function compound_process(event){
    var obj = JSON.parse(event.data);
    compound_progress ++; 
    update_page(parseInt(obj["num_modes"]));
    var info = obj["message"].split("\n");
    for(var i = 0; i < info.length; i ++){
        var paragraph = $("<p>"+ info[i] +"</p>");
        $(".log").append(paragraph)
    }
    $(".log").append($("<p>------------------------------------------------------------------------------</p>"))
}

function update_page(num_modes){
    var compound_back = compound_progress - 1;
    for(var i = 1; i <= num_modes; i++){
        $("#progressbar").css('width', ((compound_back + (i/num_modes))/compound_total) * 100 + '%')
    }
    $(".processed").text(compound_progress)
}

function finished(event){
    source.close();
    $(".progress-gif").remove();
    $(".progress-text").text(JSON.parse(event.data)["message"])
}

  

