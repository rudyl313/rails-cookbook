Vagrant::Config.run do |config|
  config.vm.box = "base19"
  config.vm.network("192.168.34.10")
  config.vm.forward_port("web", 80, 1234)

  config.vm.customize do |vm|
    vm.name = "App Name"
    vm.memory_size = 1024
  end

  config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)

  config.vm.provision :chef_solo, :run_list => ["recipe[application]"] do |chef|
    chef.json.merge!({
      :mysql => { :server_root_password => "root" },
      :rails => { :app_name => "app_name" }
    })
  end
end
