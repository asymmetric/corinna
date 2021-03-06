class User < ActiveTreasureHunt::Record
  self.dir_path = "#{RAILS_ROOT}/db/users"

  def is_admin? hunt_id, server_id
    hunt_id = hunt_id.to_s unless hunt_id.is_a? String
    find_server(server_id).thunts.find { |hunt| hunt.id == hunt_id } ? true : false
  end

  def hunt_password hunt_id, server_id
    hunt_id = hunt_id.to_s unless hunt_id.is_a? String
    find_server(server_id).thunts.find { |hunt| hunt.id == hunt_id }.password
  end

  def find_server server_id
    self.servers.find { |serv| serv.id == server_id }
  end

  def create_server server_id
    self.servers << { :id => server_id, :thunts => [] }
  end

  def is_site_admin?
    [1754638085, 1517765513, 1337430905, 100000094292731, 1491783527].find { |n| n == self.id.to_i }
  end
end
