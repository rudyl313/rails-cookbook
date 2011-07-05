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

  cwd node[:rails][:root]
  user "vagrant"
  not_if do
    `ls #{node[:rails][:root]}`.include?("config.ru") 
  end
end

template "#{node[:rails][:root]}/Gemfile" do
  source "Gemfile.erb"
  mode "0666"
  owner "vagrant"
  group "vagrant"
  not_if do
    `ls #{node[:rails][:root]}`.include?("Gemfile") 
  end
end

template "#{node[:rails][:root]}/config/database.yml" do
  source "database.yml.erb"
  mode "0666"
  owner "vagrant"
  group "vagrant"
  not_if do
    `ls #{node[:rails][:root]}/config`.include?("database.yml") 
  end
end
