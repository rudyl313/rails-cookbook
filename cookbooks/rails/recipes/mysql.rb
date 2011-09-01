require_recipe "mysql::server"
require_recipe "rails"

template "#{node[:rails][:root]}/config/database.yml" do
  source "mysql_database.yml.erb"
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

  not_if do
    `mysql -uroot -proot -e "show databases;"`.include?(node[:rails][:app_name])
  end
end
