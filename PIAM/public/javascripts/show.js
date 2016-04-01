/**
 * Created with JetBrains RubyMine.
 * User: leo
 * Date: 2/28/13
 * Time: 9:53 PM
 * To change this template use File | Settings | File Templates.
 */


$(document).ready(function(){
    $('#info-nav a:first').tab('show');
    $('#info-nav a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });


});
