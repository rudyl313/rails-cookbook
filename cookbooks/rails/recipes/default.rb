if node[:rails][:db_type] == "mysql"
  require_recipe "rails::mysql"
elsif node[:rails][:db_type] == "postgresql"
  require_recipe "rails::postgresql"
else
  raise "A valid db_type should be selected"
end
