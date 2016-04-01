/*---------------------------------------------- spinner ------------------------------------------------*/
var SPINNER = {
	load: function(target){
		$(target).ajaxStart(function() {
			$(this).addClass('spinner'); 
		}).ajaxStop(function() { 
			$(this).removeClass('spinner'); 
		});
	}
}

/*$(function(){
	SPINNER.load('.definition')
});*/
