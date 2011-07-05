#--------------------------------------------------------------------------------
# Required recipes
#--------------------------------------------------------------------------------
require_recipe "apt"
require_recipe "build-essential"
require_recipe "mysql::server"
require_recipe "apache2"

#--------------------------------------------------------------------------------
# Required packages
#--------------------------------------------------------------------------------
package "zip"
package "libxslt1-dev"

#--------------------------------------------------------------------------------
# Create rails project
#--------------------------------------------------------------------------------
gem_package "rails" do
  version node[:rails][:version]
end

bash "create_new_rails_project" do
  code <<-CODE
rails new #{node[:rails][:app_name]}
rm #{node[:rails][:app_name]}/Gemfile*
rm #{node[:rails][:app_name]}/config/database.yml
cp -r #{node[:rails][:app_name]}/* .
rm -r #{node[:rails][:app_name]}
CODE

  cwd "/vagrant"
  user "vagrant"
  not_if do
    `ls /vagrant`.include?("config.ru") 
  end
end

template "/vagrant/Gemfile" do
  source "Gemfile.erb"
  mode "0666"
  owner "vagrant"
  group "vagrant"
  not_if do
    `ls /vagrant`.include?("Gemfile") 
  end
end

template "/vagrant/config/database.yml" do
  source "database.yml.erb"
  mode "0666"
  owner "vagrant"
  group "vagrant"
  not_if do
    `ls /vagrant/config`.include?("database.yml") 
  end
end

#--------------------------------------------------------------------------------
# Install passenger
#--------------------------------------------------------------------------------
require_recipe "passenger_apache2::mod_rails"

#--------------------------------------------------------------------------------
# Rake incompatability fix
#--------------------------------------------------------------------------------
bash "downgrade-rake" do
  code "gem uninstall rake -v\"~>0.9\""

  only_if do
    `gem list rake`.include?('0.9')
  end
end

#--------------------------------------------------------------------------------
# Gems
#--------------------------------------------------------------------------------
gem_package "bundler"

execute "install bundle" do
  command "sudo bundle install"
  cwd "/vagrant"
end

#--------------------------------------------------------------------------------
# Apache
#--------------------------------------------------------------------------------
execute "disable-default-site" do
  command "sudo a2dissite default"
  notifies :restart, resources(:service => "apache2")
end

web_app "application" do
  template "application.conf.erb"
  notifies :restart, resources(:service => "apache2")
end


#--------------------------------------------------------------------------------
# Application Bootstrap
#--------------------------------------------------------------------------------
bash "db-bootstrap" do
  user "vagrant"
  cwd "/vagrant"

  code <<-CODE
rake db:create:all
rake db:migrate
rake db:test:prepare
CODE

  not_if do 
    `mysql -uroot -proot -e "show databases;"`.include?(node[:rails][:app_name])
  end
end
