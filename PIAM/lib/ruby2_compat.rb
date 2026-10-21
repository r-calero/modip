# Ruby 2.x compatibility for the asset gems locked in Gemfile.lock.
#
# Since Ruby 2.0, respond_to? ignores protected methods. Sass 3.1.x and
# Sprockets 2.1.x use respond_to? to find their own protected methods, so on
# Ruby 2.x:
#   - Sass fails to compress CSS ("undefined method `empty?' for nil").
#   - Sprockets silently ignores every //= require directive, so jquery,
#     bootstrap, etc. are left out of application.js / application.css.
# Sass 3.2 and Sprockets 2.2 fixed it with respond_to?(name, true); the
# patches below apply the same one-line fix without changing gem versions.
# They do nothing on Ruby 1.9 or on the fixed gem versions.

if RUBY_VERSION >= '2.0'
  begin
    require 'sass'
  rescue LoadError
    # Sass is only in the assets group
  end

  if defined?(Sass::VERSION) && Sass::VERSION < '3.2'
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

  require 'sprockets'

  if defined?(Sprockets::VERSION) && Sprockets::VERSION < '2.2'
    require 'shellwords'
    require 'sprockets/directive_processor'

    class Sprockets::DirectiveProcessor
      def directives
        @directives ||= header.lines.each_with_index.map { |line, index|
          if directive = line[DIRECTIVE_PATTERN, 1]
            name, *args = Shellwords.shellwords(directive)
            if respond_to?("process_#{name}_directive", true)
              [index + 1, name, *args]
            end
          end
        }.compact
      end
    end
  end
end
