#require 'chewy'

module Searchengine
  module Concerns
    module Models
      module Searchable
        extend ActiveSupport::Concern

        included do
        end

        module ClassMethods
          def searchable
            searchable_as(name) do |index|
              yield index
            end
          end

          ##
          # Creates a search index for the specified model given +name+ and
          # optional (it's in the name) +options+
          def searchable_as(name, options={}, &block)
            @search_index_name = "#{name.to_s.camelize}Index"
            set_search_index

            @search_index.class_eval(&block)
            # NOTE: Somewhat nasty implementation but as the block has most
            # likely described a new type to be available, we use that type.
            # This seemed better than forcing the user to name the type like
            # the model.
            @search_type = @search_index.types.last
            @search_index
          end

          def updatable_as(index, type=nil)
            if index.is_a? Chewy::Type
              args = [@search_type]
            else
              args = ["/searchengine/indices/#{index}##{type}"]
            end

            update_index(*args) { self } # may raise hell
          end

          def search_index
            @search_index
          end

          def search_type
            @search_type
          end

          def search_index_name
            @search_index_name
          end

          private
          def set_search_index
            @search_index = (search_indices.const_get(@search_index_name) rescue nil)
            unless @search_index
              klass = Class.new(Chewy::Index)
              @search_index = init_search_index @search_index_name, klass
            end
          end

          def init_search_index(name, value)
            Searchengine::Indices.const_set(name, value)
          end

          def search_indices
            Searchengine::Indices
          end

          def search_type_name
            self.class.to_s
          end
        end
      end
    end
  end
end
