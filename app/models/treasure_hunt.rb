class ActiveTreasureHunt < ActiveResource::Base
  class << self
#    Dunno if we need that method..
#    I have only removed the ":one" option which doesn't makes sense for us
#    def find(*arguments)
#      scope   = arguments.slice!(0)
#      options = arguments.slice!(0) || {}
#
#      case scope
#      when :all   then find_every(options)
#      when :first then find_every(options).first
#      when :last  then find_every(options).last
#      else             find_single(scope, options)
#      end
#    end

    private
    # Find every resource
    # The same but connection.get()[element_name] to get the right object
    def find_every(options)
      case from = options[:from]
      when Symbol
        instantiate_collection(get(from, options[:params]))
      when String
        path = "#{from}#{query_string(options[:params])}"
        instantiate_collection(connection.get(path, headers)[element_name] || [])
      else
        prefix_options, query_options = split_options(options[:params])
        path = collection_path(prefix_options, query_options)
        instantiate_collection((connection.get(path, headers)[element_name] || []), prefix_options )
      end
    end

    # Find a single resource from the default URL
    def find_single(scope, options)
      scope = scope.to_s unless scope.is_a? String
      prefix_options, query_options = split_options(options[:params])
      path = collection_path(prefix_options, query_options)
      connection.get(path, headers)[element_name].each do |object|
        return instantiate_record(object) if object['id'] == scope
      end
      nil
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end

    def instantiate_collection(collection, prefix_options = {})
      unless collection.kind_of? Array
        [instantiate_record(collection, prefix_options)]
      else
        collection.collect! { |record| instantiate_record(record, prefix_options) }
      end
    end
  end

end

class TreasureHunt < ActiveTreasureHunt
  self.site = 'http://localhost:3000'
  self.collection_name = 'gettreasurehunts'
end
