module Searchengine
  module Concerns
    module Models
      module Searchable
        extend ActiveSupport::Concern
  
        included do
          after_save :update_search_index
        end
  
        module ClassMethods
          def search(details)
            # TODO: compose query and return results
          end
        end

        private
        def update_search_index
          # TODO: implement
        end
      end
    end
  end
end
