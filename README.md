# OsomTables

Ajax tables engine that respects MVC and goes well with the rails way.

## The Merits

1. Rails friendly, relies on partials, scopes, etc.
2. Respects MVC, views are for views, models are for models
3. Flexible, you write your views in templates and paint them as you pleased
4. Unit testable, every moving part is independent and unit-testable
5. Light footprint, the whole thing is less than 100 lines of JS


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


## HTML5 Push State

OsomTables can easily hook you up with the html5 push-state goodness.
Yes, it's just like `pjax` (whoever come up with this name) only better
coz it renders only what needs to be rendered.

To switch push state on, just pass the `push: true` option with your table

```haml
= osom_tables_for @things, push: true do |t|
  ...
```


## Custom Urls

By default `osom-tables` will use your current url as the base one. But,
in case you would like to reuse the `_table` partial, in different locations,
you do so, but specifying the `url: smth_path` option with your tables

```haml
= osom_tables_for @things, url: other_things_path do |t|
  ...
```

## License & Copyright

All code in this repository is released under the terms of the MIT license

Copyright (C) 2013 Nikolay Nemshilov



