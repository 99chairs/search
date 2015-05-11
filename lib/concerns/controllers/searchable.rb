module Searchengine
  module Concerns
    module Controllers
      module Searchable
        extend ActiveSupport::Concern

        included do
          def search
            render :json => {}
          end
        end

        module ClassMethods
        end
      end
    end
  end
end
