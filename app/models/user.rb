class User < ActiveTreasureHunt::Record
  self.dir_path = "#{RAILS_ROOT}/db/xml"

  def is_admin?(hunt_id)
    hunt_id = hunt_id.to_s unless hunt_id.is_a? String
    not self.thunts.select { |hunt| hunt.id == hunt_id }.empty?
  end

  def is_subscribed?(hunt_id)
    hunt_id = hunt_id.to_s
    not self.subscriptions.select { |hunt| hunt.id == hunt_id }.empty?
  end

  def hunt_password(hunt_id)
    hunt_id = hunt_id.to_s unless hunt_id.is_a? String
    self.thunts.select { |hunt| hunt.id == hunt_id }.first.password
  end
end
