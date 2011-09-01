gem_package "rails" do
  version node[:rails][:version]
end

rails_new_command = "rails new " +
  node[:rails][:app_name] +
  (node[:rails][:version] >= "3.1.0" ? " --skip-bundle" : "")

bash "create_new_rails_project" do
  code <<-CODE
#{rails_new_command}
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
