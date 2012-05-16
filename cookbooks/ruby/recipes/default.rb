require_recipe "apt"
require_recipe "build-essential"

package "curl"
package "libyaml-dev"

bash "install ruby via rvm" do
  user node[:ruby][:user]
  code <<-CODE
curl -L get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install #{node[:ruby][:version]}
rvm use #{node[:ruby][:version]} --default
CODE
  environment({ 'HOME' => node[:ruby][:home], 'USER' => node[:ruby][:user] })
  not_if do
    `ls #{node[:ruby][:home]}`.include?("rvm") &&
    `find #{node[:ruby][:home]}/.rvm/ | grep ruby-`.include?(node[:ruby][:version])
  end
end
