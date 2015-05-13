module Searchengine
  module Concerns
    module Controllers
      module Searchable
        extend ActiveSupport::Concern

        included do
          def query
            warn "@search_index not available" unless @search_index
            render :json => process_query(params[:q])
          end

          private
          # A query may come in in the style `q=peter+guy`
          def process_query(params)
            res = {}
            res[:errors] = ['empty query'] if params.nil? || params[:q].empty?
            # TODO: expand this logic into a query adaptor of some sorts
            # Inspiration was the Google search API. They basically accept a
            # q param which contains the search term. In the spirit of K.I.S.S
            # this same design will be implemented here.
            res[:result] = @search_type.filter do
              q(query_string: { query: params[:q] }) 
            end
            res
          end
        end

        module ClassMethods
          def searches(index, options={})
            if index.kind_of? Class
              klass = index
            else
              klass = index.to_s.singularize.camelize.safe_constantize
            end
            @search_index = klass.search_index
            @search_type = "#{@search_index}#{klass}".safe_constantize
          end
        end
      end
    end
  end
end
