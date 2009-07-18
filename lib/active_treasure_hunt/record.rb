module ActiveTreasureHunt
  class Record < ActiveResource::Base
    class << self
      attr_accessor :dir_path

      def file_path(id)
        "#{dir_path}/#{id}.#{format.extension}"
      end

      def find(id)
        if File.file? file_path(id)
          File.open(file_path(id),"r") { |file| instantiate_record(file.read) }
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
    self.site = ""

    def save
      self.xml = ""
      File.open(self.class.file_path(id),"w") { |file| file << self.to_xml } ? true : false
    end
  end
end
