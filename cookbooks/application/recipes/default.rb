#--------------------------------------------------------------------------------
# Required recipes
#--------------------------------------------------------------------------------
require_recipe "apt"
require_recipe "build-essential"
require_recipe "apache2"
require_recipe "rails::mysql"
require_recipe "passenger_apache2::mod_rails"

#--------------------------------------------------------------------------------
# Required packages
#--------------------------------------------------------------------------------
package "zip"
package "libxslt1-dev"

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
