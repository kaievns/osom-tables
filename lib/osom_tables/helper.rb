module OsomTables::Helper

  # @param [Object] items items to be displayed, not needed if the async option is set
  # @param [Hash] options
  # @option opts [Boolean] :async Load the table content asynchronously on dom ready
  #
  # TODO: Fill all these in
  def osom_table_for(*args, &block)
    options  = args.extract_options!
    items    = args.first || []
    push     = options[:push] == true and options.delete(:push)
    url      = options[:url]   || request.path and options.delete(:url)
    search   = options[:search] == true and options.delete(:search)
    paginate = options[:paginate] || {} and options.delete(:paginate)
    show_checkbox   = options[:show_checkbox] || false
    options.delete(:show_checkbox) if options[:show_checkbox]

    url      = url.gsub(/(\?|&)osom_tables_cache_killa=[^&]*?/, '')

    # Allow the table to be loaded asynchronously
    if options[:async]
      options[:class] ||= []
      options[:class] = options[:class].split(' ') if options[:class].is_a?(String)
      options[:class] << 'async'
    end

    options[:data] ||= {}
    options[:data][:url]  = url
    options[:data][:push] = true if push

    content_tag :div, class: "osom-table #{"empty" if items.empty?}" do
      osom_tables_search(url, search) +

      content_tag(:table, options) {
        caption = if items.empty?
          content_tag(:span) { "No items to display here!" }
        else
          image_tag('osom-tables-spinner.gif', alt: nil)
        end
        content_tag(:caption, caption, class: 'locker') +
        capture(Table.new(self, items, show_checkbox), &block)
      } +

      osom_tables_pagination(items, url, paginate)
    end
  end

  def osom_tables_search(url, search)
    ''.html_safe if ! search
  end

  def osom_tables_pagination(items, url, options)
    return ''.html_safe if items.empty?
    if respond_to?(:paginate) # kaminari
      options[:params] = Rails.application.routes.recognize_path(url, method: :get).merge(options[:params] || {})
      paginate(items, options)
    elsif respond_to?(:will_paginate)
      will_paginate items, options
    else
      ''.html_safe
    end
  end

  #
  # The thing that we yield into the block
  #
  class Table
    def initialize(context, items, show_checkbox=false)
      @context = context
      @items   = items
      @show_checkbox= show_checkbox
    end

    def head(&block)
      inner, has_tr = capture_tr { yield }

      head_row = if has_tr
        inner
      else
        @context.content_tag(:tr) { inner }
      end

      while m = head_row.match(/<th(.*?) (order=("|')(.+?)\3)(.*?)>/)
        m   = m.to_a
        key = m[4]
        css = 'sortable'
        css << ' asc'  if @context.params[:order] == key
        css << ' desc' if @context.params[:order] == key + '_desc'

        [1,5].each do |i|
          if mc = m[i].match(/ class=("|')(.+)\1/)
            m[i] = m[i].gsub(mc[0], '')
            css = "#{mc[2]} #{css}"
          end
        end

        head_row.gsub! m[0], "<th#{m[1]} class='#{css}' data-#{m[2]}#{m[5]}>"
      end

      @context.content_tag :thead, head_row.html_safe
    end

    def body(&block)
      @context.content_tag :tbody do
        @items.map do |item|
          inner, has_tr = capture_tr { yield item }

          if has_tr
            inner
          elsif defined?(ActiveRecord) && item.is_a?(ActiveRecord::Base)
            @context.content_tag_for(:tr, item){ inner }
          else
            @context.content_tag(:tr){ inner }
          end
        end.join("\n").html_safe
      end
    end

    def foot(&block)
      @context.content_tag :tfoot do
        inner, has_tr = capture_tr { yield }

        if has_tr
          inner
        else
          @context.content_tag(:tr) { inner }
        end
      end
    end

    private
    def capture_tr(&block)
      inner = @context.capture do
        yield
      end

      inner.unshift "<td class='mark'><input type='checkbox' data-item-id='#{item.id}'/></td>\n" if @show_checkbox
      [inner, inner =~ /\A\s*<tr(\s|>)/i]
    end
  end
end
