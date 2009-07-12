class TreasureHunt < ActiveTreasureHunt::Base
  self.site = 'http://xanadu.doesntexist.com/stanis'
  #self.site = 'http://localhost:3001'

  self.headers = { "Accept" => "text/xml", "Content-Type" => "application/x-www-form-urlencoded" }
  self.default_request_builder = lambda do |tag, id, password, hunt|
    tag = tag.to_sym unless tag.is_a? Symbol
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.thunt tag, :hunt => hunt, :id => id, :pwd => password, :"xmlns:thunt" => "http://vitali.web.cs.unbo.it/thunt"
  end

  self.collection_name = 'gettreasurehunts'

  self.create_name = 'loadtreasurehunt'
  self.create_response_tag = 'load_treasure_hunt_result'

  self.destroy_name = 'removetreasurehunt'
  self.destroy_request_tag = 'removeTreasureHunt'
  self.destroy_response_tag = 'remove_treasure_hunt_result'
end
