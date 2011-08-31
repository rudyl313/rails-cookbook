#--------------------------------------------------------------------------------
# Required recipes
#--------------------------------------------------------------------------------
require_recipe "apt"
require_recipe "build-essential"
require_recipe "mysql::server"
require_recipe "apache2"
require_recipe "rails"
require_recipe "passenger_apache2::mod_rails"

#--------------------------------------------------------------------------------
# Required packages
#--------------------------------------------------------------------------------
package "zip"
package "libxslt1-dev"

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
# Files
#--------------------------------------------------------------------------------
cookbook_file "/home/vagrant/.bashrc" do
  source "bashrc"
  mode "0644"
end

cookbook_file "/home/vagrant/.bash_profile" do
  source "bash_profile"
  mode "0644"
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
