require 'jsonapi/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Serializable
    class SuccessRenderer
      def initialize(renderer = JSONAPI::Renderer.new)
        @renderer = renderer
      end

      # Serialize resources into a JSON API document.
      #
      # @param resources [nil,Object,Array]
      # @param options [Hash] @see JSONAPI.render
      # @option class [Class,Symbol,String,Hash{Symbol,String=>Class,Symbol,String}]
      #   The serializable resource class(es) to use for the primary resources.
      # @option namespace [String] The namespace in which to look for
      #   serializable resource classes.
      # @option inferrer [Hash{Symbol=>String}] A map specifying for each type
      #   the corresponding serializable resource class name.
      # @option expose [Hash] The exposures made available in serializable
      #   resource class instances as instance variables.
      # @return [Hash]
      #
      # @example
      #   renderer.render(nil)
      #   # => { data: nil }
      #
      # @example
      #   renderer.render(user)
      #   # => {
      #          data: {
      #            type: 'users',
      #            id: 'foo',
      #            attributes: { ... },
      #            relationships: { ... }
      #          }
      #        }
      #
      # @example
      #   renderer.render([user1, user2])
      #   # => { data: [{ type: 'users', id: 'foo', ... }, ...] }
      def render(resources, options = {})
        options   = options.dup
        klass     = options.delete(:class)
        namespace = options.delete(:namespace)
        inferrer  = options.delete(:inferrer) || default_inferrer
        inferrer  = namespace_inferrer(namespace, inferrer) if namespace
        expose    = options.delete(:expose) || {}
        resource_builder = JSONAPI::Serializable::ResourceBuilder.new(inferrer)
        exposures = expose.merge(_resource_builder: resource_builder)

        resources = resource_builder.build(resources, exposures, klass)

        @renderer.render(options.merge(data: resources))
      end

      private

      # @api private
      def default_inferrer
        Hash.new do |h, k|
          names = k.to_s.split('::')
          klass = names.pop
          h[k] = [*names, "Serializable#{klass}"].join('::')
        end
      end

      # @api private
      def namespace_inferrer(namespace, inferrer)
        Hash.new { |h, k| h[k] = "#{namespace}::#{inferrer[k]}" }
      end
    end

    class ErrorsRenderer
      def initialize(renderer = JSONAPI::Renderer.new)
        @renderer = renderer
      end

      # Serialize errors into a JSON API document.
      #
      # @param errors [Array]
      # @param options [Hash] @see JSONAPI.render
      # @return [Hash]
      #
      # @example
      #   error = JSONAPI::Serializable::Error.create(id: 'foo', title: 'bar')
      #   renderer.render([error])
      #   # => { errors: [{ id: 'foo', title: 'bar' }] }
      def render(errors, options = {})
        @renderer.render(options.merge(errors: errors))
      end
    end
  end
end
