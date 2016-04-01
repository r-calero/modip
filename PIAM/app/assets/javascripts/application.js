// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require_tree.

$(document).ready(function(){
   $(".well").css('height', $('.content').css('height'))
});

//--------------------Custom Delete Modal-----------------------
/*$('#delete-confirm').on('show', function() {
  var $submit = $(this).find('.btn-danger'),
      href = $submit.attr('href');
  $submit.attr('href', href.replace('pony', $(this).data('id')));
});

$('.delete-confirm').click(function(e) {
  e.preventDefault();
  $('#delete-confirm').data('id', $(this).data('id')).modal('show');
});*/




