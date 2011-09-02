set_unless[:rails][:version] = "3.1.0"
set_unless[:rails][:root] = "/vagrant"
set_unless[:rails][:user] = "vagrant"
set_unless[:rails][:group] = "vagrant"
set_unless[:rails][:db_user] = node[:rails][:app_name]
set_unless[:rails][:db_pass] = node[:rails][:app_name]
