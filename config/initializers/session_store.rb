# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_saasy_session',
  :secret      => '9d1cb4c1a56c842cf1af7875a0fc5d2959ee66a3d9c9d1ad03a4a0b6175364d81097bb994b31f18de97ee250aace29011dd700ae9bb0a91a07b73928be4dcc5e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store