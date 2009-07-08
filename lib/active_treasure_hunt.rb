#begin
#  require 'active_resource'
#rescue LoadError
#  activesupport_path = "#{File.dirname(__FILE__)}/../../activesupport/lib"
#  if File.directory?(activesupport_path)
#    $:.unshift activesupport_path
#    require 'active_support'
#  end
#end

require 'active_treasure_hunt/base'
require 'active_treasure_hunt/record'
#require 'active_treasure_hunt/validations'

#module ActiveResource
#  Base.class_eval do
#    include Validations
#    include CustomMethods
#  end
#end
