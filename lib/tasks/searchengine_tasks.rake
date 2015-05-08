def bulleted_list(items)
  bullet = "\n\t- "
  "#{items.count} items#{items.map { |d| bullet + d }.join}"
end

def list_indices
  Rails.application.eager_load! # damn, this will be heavy TODO: find alt
  puts "MODELS: #{bulleted_list(ActiveRecord::Base.descendants.map &:name)}"
  puts "INDICES: #{bulleted_list(Chewy::Index.descendants.map &:name)}"
end

namespace :search do
  desc 'List the models and the indices'
  task :indices => :environment do
    list_indices
  end
end
