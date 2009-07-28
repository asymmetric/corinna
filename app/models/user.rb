class User < ActiveTreasureHunt::Record
  self.dir_path = "#{RAILS_ROOT}/db/xml"

  def is_admin? hunt_id, server_id
    hunt_id = hunt_id.to_s unless hunt_id.is_a? String
    self.find_or_create_server(server_id).thunts.find { |hunt| hunt.id == hunt_id } ? true : false
  end

  def hunt_password hunt_id, server_id
    hunt_id = hunt_id.to_s unless hunt_id.is_a? String
    self.find_or_create_server(server_id).thunts.find { |hunt| hunt.id == hunt_id }.password
  end

  def find_or_create_server server_id
    server = self.servers.find { |serv| serv.id == server_id }
    unless server
      self.servers << { :id => server_id, :thunts => [] } 
      self.save
      server = self.servers.find { |serv| serv.id == server_id }
    end
    server
  end
end
