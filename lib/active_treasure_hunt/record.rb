module ActiveTreasureHunt
  class Record < ActiveResource::Base
    class << self
      attr_accessor :dir_path

      def file_path(id)
        "#{dir_path}/#{id}.#{format.extension}"
      end

      def find(arg)
        case arg
        when :all then instantiate_collection(Dir.glob("#{dir_path}/*.#{format.extension}"))
        else
          instantiate_record(file_path(arg)) if File.file? file_path(arg)
        end
      end

      def instantiate_record(record, prefix_options = {})
        new(format.decode(File.open(record,"r") { |file| file.read })).tap do |resource|
          resource.prefix_options = prefix_options
        end
      end
    end
    self.site = ""

    def save
      raise Exception.new("Can't save without an id") unless id.is_a? String
      File.open(self.class.file_path(id),"w") { |file| file << self.to_xml } ? true : false
    end

    def destroy
      File.delete(self.class.file_path(id))
    end

    def update_attribute(name, value)
      update_attributes(name => value)
    end

    def update_attributes(attributes) 
      load(attributes) && save
    end
  end
end
