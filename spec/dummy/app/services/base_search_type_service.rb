class BaseSearchTypeService
  def observe_facets
    facet_details = aggregations.map { |k, v| 
      if filters.include? k
        [k, v['buckets']]
      else
        [k, v]
      end
    }
    Hash[facet_details].with_indifferent_access
  end

  def query(params)
    type.
      query(extract_query from: params).
      filter(extract_filter from: params).
      order(extract_order from: params).
      limit(100).map(&:attributes)
  end

  def compose_filters(params)
    filter_hash = { terms: {} }
    params.map do |k, v|
      if bucket_list.include? k.to_s
        filter_hash[:terms][k] = v
      end
    end
    filter_hash
  end

  def extract_order(from: {})
    {}
  end

  def extract_query(from: {})
    { 
      multi_match: {
        query: from.with_indifferent_access[:q],
        type: 'cross_fields',
        fields: searchable_fields
      }
    }
  end

  def extract_filter(from: {})
    from = from.with_indifferent_access
    
    terms = extract_filter_terms(from: from)

    filter = []
    unless terms.empty?
      filter << [:terms, terms]
    end

    Hash[filter]
  end

  def extract_filter_terms(from: {})
    from = from.with_indifferent_access

    Hash[
      filters.select { |f| from.include? f }.map do |i|
        [field_mapping(for_attribute: i), from[i]]
      end
    ].with_indifferent_access
  end

  def type; end
  def bucket_list; [] end
end

