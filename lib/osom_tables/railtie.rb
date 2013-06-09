class OsomTables::Railtie < Rails::Railtie
  initializer "osom_tables.view_helpers" do
    ActionView::Base.send :include, OsomTables::Helper
  end
end
