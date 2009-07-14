class TreasureHunt < ActiveTreasureHunt::Base
  self.site = 'http://xanadu.doesntexist.com/stanis'
  #self.site = 'http://localhost:3001'
  #self.site = 'http://ltw0905.web.cs.unibo.it/cgi-bin/server'

  self.headers = { "Accept" => "text/xml", "Content-Type" => "application/x-www-form-urlencoded" }
  self.default_namespace = { 'thunt' => 'http://vitali.web.cs.unbo.it/thunt' }
  self.default_request_builder = lambda do |tag, id, password, hunt|
    tag = tag.to_sym unless tag.is_a? Symbol
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.thunt tag, :hunt => hunt, :id => id, :pwd => password, :"xmlns:#{self.default_namespace.keys.first}" => self.default_namespace.values.first
  end

  self.element_tag = 'treasureHunt'
  self.subscription_builder = lambda do |type, id, password, hunt|
    type = type.to_sym
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.thunt self.subscribe_name, :"xmlns:thunt" => "http://vitali.web.cs.unbo.it/thunt" do
        xml.thunt type, :thunt => hunt, :id => id, :pwd => pwd
    end
  end

  self.collection_name = 'gettreasurehunts'

  self.create_name = 'loadtreasurehunt'
  self.create_response_tag = 'loadTreasureHuntResult'

  self.destroy_name = 'removetreasurehunt'
  self.destroy_request_tag = 'removeTreasureHunt'
  self.destroy_response_tag = 'remove_treasure_hunt_result'

  self.subscribe_name = 'sendSubscription'
  self.subscribe_request_tag = self.subscribe_name
  self.subscribe_response_tag = "#{self.subscribe_name}Result".underscore
end
