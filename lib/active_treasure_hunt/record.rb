module ActiveTreasureHunt
  class Record < ActiveResource::Base
    class << self
      attr_accessor :dir_path

      def file_path(id)
        "#{dir_path}/#{id}.xml"
      end

      def find(id)
        if File.file? file_path(id)
          File.open(file_path(id),"r") { |file| instantiate_record(file) }
        end
      end

      def instantiate_record(record, prefix_options = {})
        new(Hash.from_xml(record)["user"]).tap do |resource|
          resource.prefix_options = prefix_options
        end
      end
    end
    self.site = ""

    def save
      File.open(self.class.file_path(id),"w") { |file| file << self.to_xml } ? true : false
    end
  end
end
