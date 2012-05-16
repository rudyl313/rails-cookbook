Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network :hostonly, "33.33.33.33"

  config.vm.customize do |vm|
    vm.name = "My App"
    vm.memory_size = 1024
  end

  config.vm.provision :chef_solo, :run_list => ["recipe[application]"] do |chef|
    chef.json.merge!({
      :ruby  => { :version  => "1.9.3" },
      :rails => { :app_name => "my_app",
                  :version  => "3.2.3",
                  :db_type  => "postgresql" }
    })
  end
end
