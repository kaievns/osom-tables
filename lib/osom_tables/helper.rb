module OsomTables::Helper

  def osom_table_for(items, options={}, &block)
    push     = options[:push] == true and options.delete(:push)
    url      = options[:url]   || request.fullpath and options.delete(:url)
    search   = options[:search] == true and options.delete(:search)
    paginate = options[:paginate] || {} and options.delete(:paginate)
    url      = url.gsub(/(\?|&)osom_tables_cache_killa=[^&]*?/, '')

    options[:data] ||= {}
    options[:data][:url]  = url
    options[:data][:push] = true if push

    content_tag :div, class: 'osom-table' do
      osom_tables_search(url, search) +

      content_tag(:table, options) {
        content_tag(:caption, image_tag('osom-tables-spinner.gif', alt: nil), class: 'locker') +
        capture(Table.new(self, items), &block)
      } +

      osom_tables_pagination(items, url, paginate)
    end
  end

  def osom_tables_search(url, search)
    ''.html_safe if ! search
  end

  def osom_tables_pagination(items, url, options)
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
    def initialize(context, items)
      @context = context
      @items   = items
    end

    def head(&block)
      head_row = @context.content_tag :tr, &block

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
          if defined?(ActiveRecord) && item.is_a?(ActiveRecord::Base)
            @context.content_tag_for(:tr, item){ yield(item) }
          else
            @context.content_tag(:tr){ yield(item) }
          end
        end.join("\n").html_safe
      end
    end

    def foot(&block)
      @context.content_tag :tfoot do
        @context.content_tag :tr, &block
      end
    end
  end
end
