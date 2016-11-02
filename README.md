# OsomTables

Ajax tables engine that respects MVC and goes well with the rails way.

## The Merits

1. Rails friendly, relies on partials, scopes, etc.
2. Respects MVC, views are for views, models are for models
3. Flexible, you write your views in templates and paint them as you pleased
4. Unit testable, every moving part is independent and unit-testable
5. Light footprint, the whole thing is less than 100 lines of JS

## Demo App

You can find a simple demo-app [over here](https://github.com/MadRabbit/osom-tables-app)

## Simple Setup

Add this gem to your `Gemfile`

```ruby
gem 'osom-tables'
```

Make a partial called `_table.html.haml` in your resource views

```haml
= osom_table_for @things, any_options do |t|

  = t.head do
    %th Name
    %th Size

  = t.body do |thing|
    %td= thing.name
    %td= thing.size
```

Put it into your `index.html.haml` file the usual way

```haml
%h1 Things

= render 'table'
```

Add the following thing into your controller

```ruby
class ThingsController < ApplicationController
  def index
    @things = Thing.page(params[:page])

    render partial: 'table', layout: false if request.xhr?
  end
end
```

And finally, add the assets to your `application.js` and `application.css` files the usual way

```js
 *= require 'osom-tables'
```

And you're good to go!

## Adding Checkbox

OsomTables offer show_checkbox setting to enable checkboxes on datatable

```haml
= osom_table_for @things, show_checkbox: true do |t|

  = t.head do
    %th Name
    %th Size

  = t.body do |thing|
    %td= thing.name
    %td= thing.size
```

The checked checkbox stage is able to be saved when you navigate through pages.

## Adding Sorting

OsomTables don't enforce any sort of dealing with the sorting, just use your standard scopes.
The osom-tables will just handle the views and the `params[:order]` for you.

Add the order keys to your `t.head` section like so

```haml
= osom_table_for @things do |t|

  = t.head do
    %th{order: 'name'} Name
    %th{order: 'size'} Size

  = t.body do |thing|
    %td= thing.name
    %td= thing.size
```

This will handle the `params[:order]` automatically, which you can use in your controllers say like that

```ruby
class ThingsController < ApplicationController
  def index
    @things = Thing.page(params[:page]).order_by(params[:order])

    render parital: 'table', layout: false if request.xhr?
  end
end
```

And then in your models, for example like that

```ruby
class Thing
  scope :order_by, ->(param) {
    sort = param.ends_with?('_desc') ? 'DESC' : 'ASC'

    case param.sub('_desc', '')
    when 'name' then order("name #{sort}")
    when 'size' then order("size #{sort}")
    else             scopped     # fallback
    end
  }
end
```

And don't forget to enjoy the awesomeness of easily unit-testable code!

## Sorting + Filters (JobReady implementation)

In case you want to use filtering and sorting combined, follow the example below taken from AVETARS:

```
var apply_filters = function(wrapper) {
  var form, params, table;
  form = wrapper.find("form.osom-tables-filters");
  params = extract_params(form);
  table = wrapper.find(".osom-table");
  $.store_osom_filters(table, params); // stores current filters
  $.append_osom_order(table, params); // append selected order to filters params
  return $.osom_table(table, $.param.querystring(wrapper.find(".osom-table > table").data("url"), params, 2));
};

```

## Table Reuse

By default `osom-tables` will use your current url as the url to fetch the table data. If you wish to reuse the `_table` partial from another view/controller, you must specify the `url: resource_path` option to ensure the table data is sourced correctly.

```haml
= osom_tables_for @things, url: things_path do |t|
  ...
```

## HTML5 Push State

OsomTables can easily hook you up with the html5 push-state goodness.
Yes, it's just like `pjax` (whoever come up with this name) only better
coz it renders only what needs to be rendered.

To switch push state on, just pass the `push: true` option with your table. You must also use `async: true`.

```haml
= osom_tables_for @things, async: true, push: true do |t|
  ...
```

## HTML5 Push State and Filters

When using html5 push-state with a filterbar like the one used in AVETARS, do not use `async: true` as the filterbar will handle the loading of the table data after adding filter parameters to the query string.

## License & Copyright

All code in this repository is released under the terms of the MIT license

Copyright (C) 2013 Nikolay Nemshilov



