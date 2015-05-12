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
          def searchable_as(name, options={})
            @search_index_name = "#{name.to_s.camelize}Index"
            @search_index = Searchengine::Indices.const_set(@search_index_name, Class.new(Chewy::Index))
            @search_index.class_eval do
              yield self 
            end
            @search_type = "#{@search_index}::#{self}".safe_constantize
            puts "search_type for #{@search_index}::#{self} is #{@search_type}"
            @search_index
          end

          def updatable_as(index, type)
            update_index(@search_type) { self }
            #puts "\n\r\n\r\n\rHI: #{search_type}"
            #puts "/searchengine/indices/#{index}_index##{type}"
            #puts "/searchengine/indices/#{index}_index##{type}".safe_constantize
            #update_index("/searchengine/indices/#{index}##{type}") { self }
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
        end
      end
    end
  end
end
