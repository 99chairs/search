class CharactersSearchTypeService < BaseSearchTypeService
  def aggregations
    Character.search_type.aggregations(
      category: {
        terms:  {
          field: 'category_name',
          execution_hint: 'global_ordinals_low_cardinality',
        }
      },
      unique_category_count: { cardinality: { field: 'category' } },
      category_count: { value_count: { field: 'category' } },
      description: { terms: { field: 'description' } },
    ).aggregations
  end

  def type; Character.search_type end

  def filters
    %w(category)
  end

  def searchable_fields
    %w(name description category)
  end

  # Ensure that for a given filter name, the proper field name is used.
  def field_mapping(for_attribute: nil)
    {
      category: 'category_name', # category names are indexed as category_name
    }.with_indifferent_access[for_attribute] or for_attribute
  end
end
