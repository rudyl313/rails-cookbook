require_recipe "postgresql::server"
require_recipe "rails"

package "libpq-dev"

template "#{node[:rails][:root]}/Gemfile" do
  source "Gemfile.erb"
  mode "0666"
  owner node[:rails][:user]
  group node[:rails][:group]
  not_if do
    `ls #{node[:rails][:root]}`.include?("Gemfile")
  end
  variables({
    :db_gem => "pg"
  })
end

gem_package "bundler"

execute "install bundle" do
  command "bundle install"
  cwd node[:rails][:root]
end

template "#{node[:rails][:root]}/config/database.yml" do
  source "postgresql_database.yml.erb"
  mode "0666"
  owner node[:rails][:user]
  group node[:rails][:group]
  not_if do
    `ls #{node[:rails][:root]}/config`.include?("database.yml") 
  end
end

bash "change-cluster-encoding-to-utf8" do
  code <<-CODE
pg_dropcluster --stop 8.4 main
pg_createcluster --start -e UTF-8 8.4 main
CODE
  not_if do `sudo sudo -u postgres psql -c '\\l'`.include?(node[:rails][:app_name]) end
end

bash "create-db-user" do
  user "postgres"
  code <<-CODE
psql -c "create user #{node[:rails][:db_user]} with createdb login encrypted password '#{node[:rails][:db_pass]}'"
CODE
  not_if do `sudo sudo -u postgres psql -c '\\l'`.include?(node[:rails][:app_name]) end
end

bash "db-bootstrap" do
  user node[:rails][:user]
  cwd node[:rails][:root]

  code <<-CODE
rake db:create:all
rake db:migrate
rake db:test:prepare
CODE
  not_if do `sudo sudo -u postgres psql -c '\\l'`.include?(node[:rails][:app_name]) end
end
