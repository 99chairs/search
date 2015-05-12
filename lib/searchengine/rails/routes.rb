module ActionDispatch::Routing
  class Mapper
    def searchability_for(resource, options={})
      get "#{resource}/query", to: "#{options[:controller] || resource}#query" #, as: "#{resource}_query"
    end

    ##
    # searchability_for :users # simple way
    # resources :users do # inside a resources route
    #   collection do
    #     searchable
    #   end
    # end
    def searchable
      if resource_scope?
        # TODO: raise not yet implemented
      else
        get("query", to: "#{parent_resource.controller}#query") if parent_resource # TODO: check for resource_scope? and throw error on failure
      end
    end

    private
    def route_format(resource)
      resource.to_s.underscore
    end
  end
end
