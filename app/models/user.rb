class User < ActiveTreasureHunt::Record
  self.dir_path = "#{RAILS_ROOT}/db/xml"

  def is_admin?(hunt_id)
    hunt_id = hunt_id.to_s unless hunt_id.is_a? String
    self.thunts.each { |hunt| return true if hunt.id == hunt_id }
    false
  end
end
