require 'active_treasure_hunt/errors'
module ActiveResource
  class Connection
    def get(path, headers = {})
      request(:get, path, build_request_headers(headers, :get)) # workaround for poor xml content model management
    end
  end
  class Base
    def initialize(attributes = {})
      @attributes     = {}
      @prefix_options = {}
      load(attributes) if attributes # fix ArgumentError in ActiveResource::Base#load created by poor xml content model management
    end
  end
end
module ActiveTreasureHunt
  class Base < ActiveResource::Base
    class << self
      attr_writer :headers
      attr_accessor :default_namespace, :default_request_builder, :subscription_builder, :fakehint_builder, :element_tag, :answer_builder, :status_builder, :create_response_tag, :destroy_name, :destroy_response_tag, :destroy_request_tag, :fakehint_name, :fakehint_request_tag, :fakehint_response_tag, :subscribe_name, :subscribe_request_tag, :subscribe_response_tag, :gethint_name, :gethint_request_tag, :gethint_response_tag, :start_name, :start_request_tag, :start_response_tag, :answer_name, :answer_request_tag, :answer_response_tag, :status_name, :status_request_tag, :status_response_tag
      attr_accessor_with_default(:ok_status) { "accepted" }
      attr_accessor_with_default(:no_exception_status) { %w(accepted wrong right win loose) }
      attr_accessor_with_default(:create_name) { element_name.pluralize }

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
          instantiate_collection((connection.get(path, headers).body || []))
        else
          prefix_options, query_options = split_options(options[:params])
          path = build_path(collection_name, prefix_options, query_options)
          instantiate_collection((connection.get(path, headers).body || []), prefix_options )
        end
      end

      # Find a single resource from the default URL
      def find_single(scope, options)
        scope = scope.to_s unless scope.is_a? String
        prefix_options, query_options = split_options(options[:params])
        path = build_path(collection_name, prefix_options, query_options)
        result = connection.get(path, headers)
        result = result.body unless result.is_a? String
        doc = Nokogiri::XML(result)
        object = doc.root.xpath("#{default_namespace.keys.first}:#{element_tag}[@id = #{scope}]")
        unless object.empty?
          instantiate_record(Nokogiri::XML(object.to_xml).to_xml) # ugly
        else
          raise ActiveTreasureHunt::NotExist
        end
      end

      def instantiate_collection(collection, prefix_options = {})
        if collection.kind_of? Array
          collection.collect! { |record| instantiate_record(record, prefix_options) }
        elsif collection.kind_of? String
          ugly = [] # ugly
          collection = Nokogiri::XML(collection)
          collection.root.xpath("#{default_namespace.keys.first}:#{element_tag}").each do |element|
            ugly << instantiate_record(Nokogiri::XML(element.to_xml).to_xml) # ugly^element_number
          end
          ugly
        else
          [instantiate_record(collection, prefix_options)]
        end
      end

      def instantiate_record(record, prefix_options = {})
        new_record = new(format.decode(record)).tap do |resource|
          resource.prefix_options = prefix_options
        end
        new_record.xml = record
        new_record
      end
    end

    def destroy(user_id, user_password)
      xml = self.class.default_request_builder.call(self.class.destroy_request_tag, user_id, user_password, self.id)
      connection.post(build_path(self.class.destroy_name), "xml=#{xml}", self.class.headers).tap do |response|
        validate_response(extract_body(response, self.class.destroy_response_tag))
      end
    end

    def fakehint(hint, turn, id, pwd)
      xml = self.class.fakehint_builder.call(hint, turn, id, pwd, self.id)
      connection.post(build_path(self.class.fakehint_name), "xml=#{xml}", self.class.headers).tap do |response|
        validate_response(extract_body(response, self.class.fakehint_response_tag))
      end
    end

    def subscribe(type, id, pwd)
      xml = self.class.subscription_builder.call(type, id, pwd, self.id)
      connection.post(build_path(self.class.subscribe_name), "xml=#{xml}", self.class.headers).tap do |response|
        validate_response response.body
      end
    end

    def start(id, pwd)
      xml = self.class.default_request_builder.call(self.class.start_request_tag, id, pwd, self.id)
      connection.post(build_path(self.class.start_name), "xml=#{xml}", self.class.headers).tap do |response|
        validate_response(extract_body(response, self.class.start_response_tag))
      end
    end

    def gethint(id, pwd)
      xml = self.class.default_request_builder.call(self.class.gethint_request_tag, id, pwd, self.id)
      connection.post(build_path(self.class.gethint_name), "xml=#{xml}", self.class.headers).tap do |response|
        body = extract_body(response, self.class.gethint_response_tag)
        validate_response body
        self.xml = response.body
      end
      self.xml
    end

    def status(id,pwd)
      xml = self.class.default_request_builder.call(self.class.status_request_tag, id, pwd, self.id)
      connection.post(build_path(self.class.status_name), "xml=#{xml}", self.class.headers).tap do |response|
        validate_response response.body
        self.xml = response.body
      end
      self.xml
    end

    def answer answer_xml, type, id, pwd
      xml = self.class.answer_builder.call(answer_xml, type, id, pwd, self.id)
      st = ""
      connection.post(build_path(self.class.answer_name), "xml=#{xml}", self.class.headers).tap do |response|
        body = extract_body response, self.class.answer_response_tag
        validate_response body
        st = body['status']
      end
      st
    end

    protected
    def build_path(action_name, options = nil)
      self.class.build_path(action_name, options || prefix_options)
    end

    # Create (i.e., \save to the remote service) the \new resource.
    def create
      connection.post(build_path(self.class.create_name), "xml=#{self.xml}", self.class.headers).tap do |response|
        body = extract_body(response, self.class.create_response_tag)
        validate_response(body)
        self.id = id_from_response(body)
        load_attributes_from_response(response)
      end
    end

    def id_from_response(body)
      body['hunt']
    end

    def extract_body(response, response_name)
      self.class.format.decode(response.body)
    end

    def validate_response(body)
      status = case body
               when Hash
                 body['status']
               when String
                xml = Nokogiri::XML body
                xml.root.xpath('@status').to_s
               end

      unless self.class.no_exception_status.member? status
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
