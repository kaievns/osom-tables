/**
 * The OsomTables scriptery
 *
 * Copyright (C) 2013 Nikolay Nemshilov
 */
(function($) {

  if (!$) { return console.log("No jQuery? Osom!"); }

  $(document).on('click', '.osom-table .pagination a', function(e) {
    e.preventDefault();

    var container = $(this).closest('.osom-table');
    var push      = container.data('push');
    var url       = container.data('url');

    container.addClass('loading');

    $.get(this.getAttribute('href'), function(result) {
      container.html(result);
      container.removeClass('loading');
    });
  });

})(jQuery);
