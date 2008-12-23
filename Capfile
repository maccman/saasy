# Configuration
role :app, "account.crowdmod.com"
role :web, "account.crowdmod.com"
role :db,  "account.crowdmod.com", :primary => true

set :application, "saas"
set :use_mysql, false
set :thin_socket, true
set :thin_port, 8000
set :thin_number, 1

set :svn_user, ENV['svn_user'] || "alex"
set :svn_url, "svn://svn.alexmaccaw.co.uk:8100"

ssh_options[:keys] = File.expand_path('~/keys/aireo_keypair')

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'
