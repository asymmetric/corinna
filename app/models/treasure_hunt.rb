class TreasureHunt < ActiveTreasureHunt::Base
  self.site = 'http://xanadu.doesntexist.com/stanis'
  #self.site = 'http://localhost:3001'
  self.collection_name = 'gettreasurehunts'
  self.create_name = 'loadtreasurehunt'
  self.headers = { "Accept" => "text/xml", "Content-Type" => "application/x-www-form-urlencoded" }
end
