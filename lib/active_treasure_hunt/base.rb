require 'active_treasure_hunt/errors'
module ActiveTreasureHunt
  class Base < ActiveResource::Base
    class << self
      attr_accessor_with_default(:create_name) { element_name.pluralize }
      attr_accessor :create_response_name
      attr_accessor :remove_name
      attr_accessor :remove_response_name
      attr_accessor_with_default(:ok_status) { 'accepted' }
      attr_writer :headers

      def build_path(action_name, prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{action_name}#{query_string(query_options)}"
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
          path = build_path(collection_name, prefix_options, query_options)
          instantiate_collection((connection.get(path, headers)[element_name] || []), prefix_options )
        end
      end

      # Find a single resource from the default URL
      def find_single(scope, options)
        scope = scope.to_s unless scope.is_a? String
        prefix_options, query_options = split_options(options[:params])
        path = build_path(collection_name, prefix_options, query_options)
        result = connection.get(path, headers)[element_name]
        unless result.kind_of? Array
          return instantiate_record(result) if result['id'] == scope
        else
          result.each { |object| return instantiate_record(object) if object['id'] == scope }
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
    def build_path(action_name, options = nil)
      self.class.build_path(action_name, options || prefix_options)
    end

    # Create (i.e., \save to the remote service) the \new resource.
    def create
      connection.post(build_path(self.class.create_name), "xml=#{attributes['xml']}", self.class.headers).tap do |response|
        body = extract_body(response, self.class.create_response_name)
        validate_response(body)
        self.id = id_from_response(body) #TODO
        load_attributes_from_response(body) #TODO
      end
    end

    def extract_body(response, response_name)
      Hash.from_xml(response.body)[response_name]
    end

    def validate_response(body)
      status = body['status']
      if status && status != self.class.ok_status
        begin
          error_class = ActiveTreasureHunt::const_get(status.gsub(/^(\w)/) { $1.mb_chars.capitalize })
        rescue NameError => e
          raise ActiveResource::ConnectionError.new(status, "Unknown error")
        end
        raise error_class.new
     end
    end
  end
end
