# -*- coding: utf-8 -*-
class Server < ActiveTreasureHunt::Record
  self.dir_path = "#{RAILS_ROOT}/db/servers"
  def self.default
    self.find("rené")
  end
end
