class ActiveTreasureHunt < ActiveResource::Base
  class << self

    # remove trailing .xml to urls
    def collection_path(prefix_options = {}, query_options = nil)
      "#{prefix(prefix_options)}#{collection_name}"
    end

    # prevent NoMethodError: undefined method `collect!' for #<Hash:0x16595b8>
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
  self.site = "http://localhost:3000"
  self.collection_name = "gettreasurehunts"
end
