class ActiveTreasureHunt < ActiveResource::Base
  class << self
    attr_accessor_with_default(:create_name) { element_name.pluralize }

    def create_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{create_name}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end

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
      nil # FIXME: throw exception (which?)
    end

    def instantiate_collection(collection, prefix_options = {})
      unless collection.kind_of? Array
        [instantiate_record(collection, prefix_options)]
      else
        collection.collect! { |record| instantiate_record(record, prefix_options) }
      end
    end
  end

  protected
  def create_path(options = nil)
    self.class.create_path(options || prefix_options)
  end
  # Create (i.e., \save to the remote service) the \new resource.
  def create
    connection.post(create_path, "xml=#{attributes[:xml]}", self.class.headers).tap do |response|
      self.id = id_from_response(response)
      load_attributes_from_response(response)
    end
  end
end

class TreasureHunt < ActiveTreasureHunt
  self.site = 'http://xanadu.doesntexist.com/stanis'
  self.collection_name = 'gettreasurehunts'
  self.create_name = 'loadtreasurehunt'
end
