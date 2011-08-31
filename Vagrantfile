Vagrant::Config.run do |config|
  config.vm.box = "lucid19"
  config.vm.box_url = "http://dl.dropbox.com/u/8443957/lucid19.box"

  config.vm.network("192.168.34.10")

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
