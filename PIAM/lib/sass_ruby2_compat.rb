# Sass 3.1.x (locked at 3.1.15) checks `respond_to?(method)` to find its
# protected visit_* methods. Since Ruby 2.0 respond_to? ignores protected
# methods, so CSS compression fails with "undefined method `empty?' for nil".
# Sass 3.2 fixed it with respond_to?(method, true); this applies the same fix
# without changing the gem version. It does nothing on Ruby 1.9 or Sass >= 3.2.
begin
  require 'sass'
rescue LoadError
  # Sass is only in the assets group
end

if defined?(Sass::VERSION) && RUBY_VERSION >= '2.0' && Sass::VERSION < '3.2'
  require 'sass/tree/visitors/base'

  class Sass::Tree::Visitors::Base
    def visit(node)
      method = "visit_#{node_name node}"
      if respond_to?(method, true)
        send(method, node) { visit_children(node) }
      else
        visit_children(node)
      end
    end
  end
end
