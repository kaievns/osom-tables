class OsomTables::Railtie < Rails::Railtie
  initializer "osom_tables.view_helpers" do
    ActionView::Base.send :include, OsomTables::Helper
  end

  initializer "osom_tables.configure_rails_initialization" do
    ActionController::Base.instance_eval do
      before_filter do
        params.delete(:sneaky_cache_killa)
      end
    end
  end
end
