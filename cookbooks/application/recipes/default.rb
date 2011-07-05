require_recipe "rails"

cookbook_file "/home/vagrant/.bashrc" do
  source "bashrc"
  mode "0644"
end

cookbook_file "/home/vagrant/.bash_profile" do
  source "bash_profile"
  mode "0644"
end
