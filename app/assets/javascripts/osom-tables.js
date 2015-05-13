/**
 * The OsomTables scriptery
 *
 * Copyright (C) 2013 Nikolay Nemshilov
 */
(function($) {

  if (!$) { return console.log("No jQuery? Osom!"); }

  var current_table = null;

  /**
   * Rebuilds the url with the extra prams
   */
  function build_url(url, params) {
    var path, args; path = parse_url(url);
    args = path[1]; path = path[0];

    for (var key in params) {
      args[key] = params[key];
    }

    return path + "?" + $.param(args);
  }

  /**
   * Parsing the arguments out of the url query
   */
  function parse_url(url) {
    var path, query, args={}, list, key, value;
    path = url.split("?"); query = path[1]; path = path[0];

    if (query) {
      for (var i=0, list = query.split('&'); i < list.length; i++) {
        key   = list[i].split('=');
        value = key[1]; key = key[0];

        key   = decodeURIComponent(key);
        value = decodeURIComponent((value||'').replace(/\+/g, ' '));

        if (key.substr(-2) === "[]") {
          if (args[key]) {
            args[key].push(value)
          } else {
            args[key] = [value]
          }
        } else {
          args[key] = value
        }
      }
    }

    return [path, args];
  }

  var osom_table = $.fn.osom_table = $.osom_table = function(container, url, no_push) {
    current_table = container.addClass('loading');
    actual_table  = container.find('table');

    actual_table.trigger('osom-table:request');

    if (history.pushState && !no_push && actual_table.data('push')) {
      history.pushState({url: url}, 'osom-table', url);
      url = build_url(url, {osom_tables_cache_killa: true});
    }

    $.ajax(url, {
      success: function(new_content) {
        var new_container = $(new_content);
        container.replaceWith(new_container);

        var actual_table = new_container.find('table');
        actual_table.data('url', url);
      },
      complete: function() {
        container.removeClass('loading');
        actual_table.trigger('osom-table:loaded');
      }
    });
  };

  $(document).on('click', '.osom-table .pagination a', function(e) {
    e.preventDefault();
    $.osom_table($(this).closest('.osom-table'), this.getAttribute('href'));
  });

  $(document).on('click', '.osom-table th[data-order]', function(e) {
    var order = $(this).data('order'), asc = $(this).hasClass('asc');

    $.osom_table($(this).closest('.osom-table'), build_url(
      $(this).closest('table').data('url'), {
        order: order + (asc ? '_desc' : ''), page: 1
      }
    ));
  });

  /* Load async tables */
  $(document).ready(function() {
    $('.osom-table .async').each(function(index, element) {
      var table = $(element);
      return $.osom_table(table.closest('.osom-table'), table.data('url'));
    });
  });

  $(window).on('popstate', function(e) {
    var state = e.originalEvent.state;
    if (state && state.url) {
      if (current_table && current_table.find('table').data('push')) {
        $.osom_table(current_table, state.url, true);
      } else {
        document.location.href = state.url;
      }
    }
  });

})(jQuery);
