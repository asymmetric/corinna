class User < ActiveTreasureHunt::Record
  self.dir_path = "#{RAILS_ROOT}/db/xml"

  def is_admin?(hunt_id)
    hunt_id = hunt_id.to_s unless hunt_id.is_a? String
    self.thunts.find { |hunt| hunt.id == hunt_id } ? true : false
  end

  def hunt_password(hunt_id)
    hunt_id = hunt_id.to_s unless hunt_id.is_a? String
    self.thunts.find { |hunt| hunt.id == hunt_id }.password
  end
end
