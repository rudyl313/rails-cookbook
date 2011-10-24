require_recipe "apt"

package "libxml2-dev"
package "libxslt1-dev"

gem_package "rails" do
  version node[:rails][:version]
end

rails_new_command = "rails new " +
  node[:rails][:app_name] +
  (node[:rails][:version] >= "3.1.0" ? " --skip-bundle" : "")

bash "create new rails project" do
  user node[:rails][:user]
  cwd node[:rails][:root]
  code <<-CODE
#{rails_new_command}
rm #{node[:rails][:app_name]}/Gemfile*
rm #{node[:rails][:app_name]}/config/database.yml
cp -r #{node[:rails][:app_name]}/* .
rm -r #{node[:rails][:app_name]}
CODE
  not_if do
    `ls #{node[:rails][:root]}`.include?("config.ru") 
  end
end
