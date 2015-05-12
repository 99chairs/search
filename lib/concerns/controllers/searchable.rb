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
          def process_query(params)
            res = {}
            res[:errors] = ['empty query'] if params.nil? || params[:q].empty?
            {}
          end
        end

        module ClassMethods
          def searches(index, options={})
            if index.kind_of? Class
              klass = index
            else
              klass = index.to_s.singularize.camelize.constantize
            end
            @search_index = klass.search_index
          end
        end
      end
    end
  end
end
