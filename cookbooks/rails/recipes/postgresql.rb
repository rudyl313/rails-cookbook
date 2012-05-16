require_recipe "postgresql"
require_recipe "rails::common"

package "libpq-dev"

template "#{node[:rails][:app_root]}/Gemfile" do
  source "Gemfile.erb"
  mode "0666"
  owner node[:rails][:user]
  group node[:rails][:group]
  variables({ :db_gem => "pg" })
  not_if { `ls #{node[:rails][:app_root]}`.include?("Gemfile") }
end

bash "install bundle" do
  user node[:rails][:user]
  cwd node[:rails][:app_root]
  code <<-CODE
source ~/.rvm/scripts/rvm
bundle install
CODE
  environment(node[:rails][:bash_env])
end

template "#{node[:rails][:app_root]}/config/database.yml" do
  source "postgresql_database.yml.erb"
  mode "0666"
  owner node[:rails][:user]
  group node[:rails][:group]
  not_if { `ls #{node[:rails][:app_root]}/config`.include?("database.yml") }
end

bash "change-cluster-encoding-to-utf8" do
  code <<-CODE
pg_dropcluster --stop 9.1 main
pg_createcluster --start -e UTF-8 9.1 main
CODE
  not_if { `sudo sudo -u postgres psql -c '\\l'`.include?(node[:rails][:app_name]) }
end

bash "create-db-user" do
  user "postgres"
  code <<-CODE
psql -c "create user #{node[:rails][:db_user]} with createdb login encrypted password '#{node[:rails][:db_pass]}'"
CODE
  not_if { `sudo sudo -u postgres psql -c '\\l'`.include?(node[:rails][:app_name]) }
end

bash "db-bootstrap" do
  user node[:rails][:user]
  cwd node[:rails][:app_root]
  environment(node[:rails][:bash_env])
  code <<-CODE
source ~/.rvm/scripts/rvm
rake db:create:all
rake db:migrate
rake db:test:prepare
CODE
  not_if { `sudo sudo -u postgres psql -c '\\l'`.include?(node[:rails][:app_name]) }
end
