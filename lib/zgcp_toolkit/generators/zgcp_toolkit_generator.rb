require 'rails/generators'

class ZgcpToolkitGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def copy_initializer
    template "zgcp_toolkit.rb", "config/initializers/zgcp_toolkit.rb"
  end
end
