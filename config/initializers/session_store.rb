# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_thc_session',
  :secret      => '4f318b622478c668372dfd5522108b3d01505cd09c5d4887a2feace2d837cb7ba79704245326ffac2357381725d50e9c7a9093df97f836e1ff05ff82bc148400'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
