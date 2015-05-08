#require 'chewy'

module Searchengine
  module Concerns
    module Models
      module Searchable
        extend ActiveSupport::Concern
  
        included do
          #after_save :update_search_index
        end

        module ClassMethods
          def searchable
            searchable_as(name) do
              yield
            end
          end

          ##
          # Creates a search index for the specified model given +name+ and 
          # optional (it's in the name) +options+
          def searchable_as(name, options={})
            @index_name = "#{name}Index"
            @index = Searchengine::Indices.const_set(@index_name, Class.new(Chewy::Index))
            @index.class_eval do
              yield
            end
            @index
          end

          def search_index
            @index
          end

          def search_index_name
            @index_name
          end

          def build_search_index
            #yield
          end
        end
      end
    end
  end
end
