node[:mysql][:server_root_password] = "root"

require_recipe "mysql::server"
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
    :db_gem => "mysql"
  })
end

gem_package "bundler"

execute "install bundle" do
  command "bundle install"
  cwd node[:rails][:root]
end

bash "setup database user" do
  code <<-CODE
mysql -u root -proot -e "CREATE USER '#{node[:rails][:db_user]}'@'localhost' IDENTIFIED BY '#{node[:rails][:db_pass]}';"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO '#{node[:rails][:db_user]}'@'localhost' WITH GRANT OPTION;"
CODE
  not_if do `mysql -u root -proot -e "SELECT * FROM mysql.user;"`.include?(node[:rails][:db_user]) end
end

template "#{node[:rails][:root]}/config/database.yml" do
  source "mysql_database.yml.erb"
  mode "0666"
  owner node[:rails][:user]
  group node[:rails][:group]
  not_if do
    `ls #{node[:rails][:root]}/config`.include?("database.yml") 
  end
end

bash "db bootstrap" do
  user node[:rails][:user]
  cwd node[:rails][:root]

  code <<-CODE
rake db:create:all
rake db:migrate
rake db:test:prepare
CODE

  not_if do
    `mysql -u #{node[:rails][:db_user]} -p#{node[:rails][:db_pass]} -e "show databases;"`.include?(node[:rails][:app_name])
  end
end
