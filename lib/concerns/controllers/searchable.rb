module Searchengine
  module Concerns
    module Controllers
      module Searchable
        extend ActiveSupport::Concern

        included do
          def query
            render :json => self.class.process_query(params)
          end
        end

        module ClassMethods
          def process_query(params)
            warn "index or type are nil" if @search_index.nil? || @search_type.nil?
            res = {}
            res[:errors] = ['empty query'] if params.nil? || params[:q].nil? || params[:q].empty?
            # TODO: expand this logic into a query adaptor of some sorts
            # Inspiration was the Google search API. They basically accept a
            # q param which contains the search term. In the spirit of K.I.S.S
            # this same design will be implemented here.
            results = find(params[:q], params)
            res[:responseData] = {
              timeElapsed: results.took,
              total_hits: results.total_count,
              count: results.count,
              results: results.map { |r| r.attributes }
            }
            res
          end

          def find(phrase, options={})
            construct_query(phrase, options)
          end

          def searches(searchable, options={})
            if searchable.kind_of? Class
              klass = searchable
            else
              klass = searchable.to_s.singularize.camelize.safe_constantize
            end
            @search_index = klass.search_index
            @search_type = klass.search_type
          end

          def construct_query(phrase, options={})
            options = ActiveSupport::HashWithIndifferentAccess.new(options)
            query_details = { 
              query_string: {
                query: phrase,
                analyze_wildcard: true
              }
            }

            size  = (options[:size]  if options.key?(:size))  || 10
            start = (options[:start] if options.key?(:start)) ||  0
            @search_type.query(query_details).limit(size).offset(start)
          end
        end
      end
    end
  end
end
