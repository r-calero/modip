/**
 * Created with JetBrains RubyMine.
 * User: leo
 * Date: 4/4/13
 * Time: 11:05 AM
 * To change this template use File | Settings | File Templates.
 */

$(document).ready(function(){
    if($("#schedule").attr('checked') != 'checked'){
        $(".schedule").hide();
    }
    else{
      $(".schedule").show();
    }
    $(".advance").hide();
});

$(document).ready(function(){
    $("#schedule").click(function(){
        checkbox = $(this);
        if (checkbox.attr('checked') == 'checked'){
            $(".schedule").show();
        }
        else{
            $(".schedule").hide();
        }

    })
});

$(document).ready(function(){
    $("#advance_search").click(function(){
        checkbox = $(this);
        if (checkbox.attr('checked') == 'checked'){
            $("textarea").attr('disabled', true);
            $(".advance").show();
        }
        else{
            $("textarea").attr('disabled', false);
            $(".advance").hide();
        }

    });
});

$(document).ready(function(){
   $('.text-search').keyup(function(){
       key_up($(this).parent(), true);
   });
  /* $('.date_from').keyup(function(){
       key_up($(this));
   });*/

});

function key_up(input_wrap, expand){
    if(expand && input_wrap.parent().attr('position') == "last"){
        input_wrap.parent().attr('position', 'middle');
        var div =$("<div></div>").addClass("advance-search");
        div.attr('position', 'last');
        div.append(input_wrap.parent().find("> select:first").clone());
        var field = input_wrap.parent().find("> select:last").clone();
        field.css('margin-left', '5px');
        field.css('margin-right', '5px');
        field.change(function(){change_field(field)});
        div.append(field);
        var input_wrap = $("<div></div>").addClass("input_wrap");
        var input = $("<input>").addClass("text-search");
        input.attr('type', 'text');
        input.keyup(function(){key_up(input_wrap, true)});
        input_wrap.append(input);
        div.append(input_wrap);

        $(".advance").append(div);
    }
    var query = compound_query();
    $("#query_query").val(query);

    
        
    
}

function get_option_selected(s) {
            for(var i = 0; i < s.length; i++){
                if(s.options[i].selected){
                     return {0:s.options[i].value, 1:s.options[i].text};
                }
            }
            return {0:"string",1:"All Fields"};
        }

function compound_query() {
        var query = "";
        var texts = [];
        var index = [];
        var rows = $(".advance-search");
        var field = null;
        var input_wrap = null;
        var value = "";
        for(var i = 0; i < rows.length; i++){
            field = get_option_selected(rows[i].children[1]);
            input_wrap = rows[i].children[2];
            value =  field[0] == "date" ? input_wrap.children[1].children[0].value : input_wrap.children[0].value;
            var tmpValue = value.replace(/\s/g, "");
            if(tmpValue != ""){
                index.push(i);
                if(field[0] == "numerical"){
                   if(value.match(/:/)){
                       texts.push(value + "[" + field[1] + "]")
                   }
                   else{
                       texts.push("0:" + value + "[" + field[1] + "]")
                   }
                }
                else if (field[0] == "date"){
                   if(value != 'YYYY/MM/DD'){
                    var to_date = input_wrap.children[1].children[2].value;
                    if(to_date != "present" && to_date != ""){
                        texts.push("(" + "\"" + value + "\""+ "[" + field[1] + "]"  + ":" + "\"" + to_date + "\""+ "[" + field[1] + "]" + ")")
                    }
                    else{
                        texts.push("(" + "\"" + value + "\""+ "[" + field[1] + "]"  + ":" + "\"3000\""+ "[" + field[1] + "]" + ")")
                    }
                   }
                   else{index.pop()}
                }
                else if(field[0] == "string"){
                    texts.push("\"" + value + "\"" + "[" + field[1] + "]")
                }
                else{texts.push(value)}
            }
            else{texts.push(tmpValue)}
        }
        if(index.length > 1){
            query = "(" + texts[index[0]] + ")";
            for(var j= 1; j < index.length; j ++){
                query = "(" + query + ")" + " " + get_option_selected(rows[index[j]].children[0])[1] + " " + texts[index[j]]
            }
        }
        else if(index.length == 1){ query = texts[index[0]]}
        else query = "";
        return query;
}

$(document).ready(function(){
   $(".field").change(function(){
       change_field($(this));

   })
   $(".logic").change(function(){
   		 $("#query_query").val(compound_query())
   })
});

function change_field(current){
    var field = current.val();
    var parent = current.parent();
    var input_wrap = parent.find("> div:first");
    if(field == "date"){
        parent.attr('type', 'date');
        input_wrap.find("> input:first").hide();
        var date_input_text = input_wrap.find("> span:first");
        if(date_input_text.length == 0){
            date_input_text = $("<span></span>").addClass('dateinputtext');
            var date_from = $("<input type='text' placeholder = 'YYYY/DD/MM'>").addClass('date_from').attr('maxlength', 10);
//          //date_from.css('margin-left', '5px');
            var date_to = $("<input type='text' placeholder = 'present'>").addClass('date_to').attr('maxlength', 10);
            date_from.keyup(function(){key_up(input_wrap, true)});
            date_to.keyup(function(){key_up(input_wrap, false)});
            date_input_text.append(date_from);
            date_input_text.append($("<label>to</label>"));
            date_input_text.append(date_to);
            input_wrap.append(date_input_text);
        }
        else{date_input_text.show()}
    }
    else if(parent.attr('type') == 'date'){
        parent.attr('type', 'text');
        input_wrap.find("> input:first").show();
        input_wrap.find("> span:first").hide();
        /*parent.find("> input:last").remove();
         parent.find("> label").remove();
         var input = parent.find("> input:first").removeClass();
         input.addClass('text-search');
         input.val('');*/
    }

}

/*$(document).ready(function(){
    var advance = $(".params");
    var oThis = this;
    advance.find(".date_from").live('focus',function(){
        oThis = $(this);
        if (oThis.val() == "YYYY/MM/DD"){
            oThis.val("");
            oThis.removeClass("blurred");
        }
    }).live('blur', function(){
            oThis = $(this);
            if (oThis.val() == ""){
                oThis.val("YYYY/MM/DD");
                oThis.addClass("blurred");
            }
        });


    advance.find(".date_to").live('focus',function(){
        oThis = $(this);
        if (oThis.val() == "present"){
            oThis.val("");
            oThis.removeClass("blurred");
        }
    }).live('blur', function(){
            oThis = $(this);
            if (oThis.val() == ""){
                oThis.val("present");
                oThis.addClass("blurred");
            }
        });

});*/


$(document).ready(function(){
    $("form").submit(function(){
        var min_date = $(".date")[0];
        var max_date = $(".date")[1];

        if(min_date.value == "YYYY/MM/DD" || min_date.value == ""){
            min_date.value = null;
        }
        if(max_date.value == "YYYY/MM/DD" || max_date.value == ""){
            max_date.value = null;
        }
        $("textarea").attr('disabled', false);
    })
});
