class TreasureHunt
  include HTTParty
  base_uri 'localhost:3000'
  format :xml
  headers 'Accept' => 'text/xml'

  class << self
    def create(hash)
      # load
      # fetch id from xml
      self.new(hash) # done :)
    end

    def find(*arguments)
      scope   = arguments.slice!(0)
      options = arguments.slice!(0) || {}

      case scope
      when :all   then find_every(options)
      when :first then find_every(options).first
      when :last  then find_every(options).last
      else             find_single(scope, options)
      end
    end

    def delete(id)
      # remove
    end

    def exists?(id)
    end

    private
    def find_every(options)
      instantiate_collection(fetch_collection)
    end

    def find_single(scope, options)
      unless scope.is_a? String
        scope = scope.to_s
      end

      fetch_collection.each do |object|
        return instantiate_record(object) if object['id'] == scope
      end
      nil # ugly
    end
    
    def fetch_collection
      get(collection_path)['thunt:getTreasureHunts']['thunt:treasureHunt'] # TODO ugly ugly ugly!
    end

    attr_accessor :collection_name
    def collection_path
      "/#{collection_name}" # TODO prefix, prefix_path, prefix_options
    end
    def instantiate_collection(collection)
      unless collection.kind_of? Array
        [instantiate_record(collection)]
      else
        collection.collect! { |record| instantiate_record(record) }
      end
    end
    def instantiate_record(record)
      new(record)
    end
  end
  self.collection_name = 'gettreasurehunts'

  attr_reader :id, :title, :description
  def initialize(hash)
    @id = hash['id']
    @title = hash['title']
    @description = hash['thunt:description']
  end

  def new?
    id.nil? # doesn't work anymore
  end

  def save
    new? ? create : update
  end
  
  def destroy
  end

  protected

  def create
  end

  def update
  end
end
