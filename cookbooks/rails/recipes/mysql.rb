require_recipe "mysql"
require_recipe "rails::common"

template "#{node[:rails][:app_root]}/Gemfile" do
  source "Gemfile.erb"
  mode "0666"
  owner node[:rails][:user]
  group node[:rails][:group]
  variables({ :db_gem => "mysql" })
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

bash "setup database user" do
  code <<-CODE
mysql -u root -e "CREATE USER '#{node[:rails][:db_user]}'@'localhost' IDENTIFIED BY '#{node[:rails][:db_pass]}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '#{node[:rails][:db_user]}'@'localhost' WITH GRANT OPTION;"
CODE
  not_if { `mysql -u root -e "SELECT * FROM mysql.user;"`.include?(node[:rails][:db_user]) }
end

template "#{node[:rails][:app_root]}/config/database.yml" do
  source "mysql_database.yml.erb"
  mode "0666"
  owner node[:rails][:user]
  group node[:rails][:group]
  not_if { `ls #{node[:rails][:app_root]}/config`.include?("database.yml") }
end

bash "db bootstrap" do
  user node[:rails][:user]
  cwd node[:rails][:app_root]
  environment(node[:rails][:bash_env])
  code <<-CODE
source ~/.rvm/scripts/rvm
bundle exec rake db:create:all
bundle exec rake db:migrate
bundle exec rake db:test:prepare
CODE
  not_if do
    `mysql -u #{node[:rails][:db_user]} -p#{node[:rails][:db_pass]} -e "show databases;"`.include?(node[:rails][:app_name])
  end
end
