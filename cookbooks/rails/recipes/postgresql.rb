require_recipe "postgresql::server"
require_recipe "rails"

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

bash "db-bootstrap" do
  user node[:rails][:user]
  cwd node[:rails][:root]

  code <<-CODE
rake db:create:all
rake db:migrate
rake db:test:prepare
CODE
end
