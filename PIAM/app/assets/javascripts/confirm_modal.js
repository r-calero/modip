// Confirmation dialogs with a Bootstrap modal instead of the browser's
// confirm(). Every link or button with data-confirm (":confirm => ..." in
// Rails) uses it. Optional attributes:
//   data-confirm-title  modal title (default "Please confirm")
//   data-confirm-ok     text of the confirm button (default "OK")
//   data-confirm-style  danger (default) or primary
// Texts are inserted as text, never as HTML.
(function ($) {
  var modal = null, pending = null;

  function build() {
    modal = $(
      '<div class="modal hide fade" id="confirm-modal" tabindex="-1" role="dialog" aria-labelledby="confirm-modal-title" aria-hidden="true">' +
        '<div class="modal-header">' +
          '<a class="close" data-dismiss="modal"><span class="badge badge-important">x</span></a>' +
          '<h3 id="confirm-modal-title"></h3>' +
        '</div>' +
        '<div class="modal-body"><p id="confirm-modal-message"></p></div>' +
        '<div class="modal-footer">' +
          '<a href="#" class="btn" id="confirm-modal-cancel" data-dismiss="modal">Cancel</a>' +
          '<a href="#" class="btn btn-danger" id="confirm-modal-ok">OK</a>' +
        '</div>' +
      '</div>').appendTo(document.body);
    modal.find('#confirm-modal-ok').on('click', function (e) {
      e.preventDefault();
      var element = pending;
      pending = null;
      modal.modal('hide');
      if (element) {
        element.data('confirmed', true);
        element.trigger('click');
      }
    });
    modal.on('hidden', function () { pending = null; });
  }

  $.rails.allowAction = function (element) {
    var message = element.data('confirm');
    if (!message) { return true; }
    if (element.data('confirmed')) {
      element.removeData('confirmed');
      return true;
    }
    if (!modal) { build(); }
    pending = element;
    modal.find('#confirm-modal-title').text(element.data('confirm-title') || 'Please confirm');
    modal.find('#confirm-modal-message').text(message);
    modal.find('#confirm-modal-ok').text(element.data('confirm-ok') || 'OK')
      .attr('class', 'btn ' + (element.data('confirm-style') === 'primary' ? 'btn-primary' : 'btn-danger'));
    modal.modal('show');
    return false;
  };
})(jQuery);
