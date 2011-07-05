replacement_gid = node[:nfs_user][:replacement_gid].to_i
user_map = {}
group_map = {}

[node[:nfs_user][:folders]].flatten.each do |folder|
  stat = File.stat(folder)

  user_map[stat.uid] ||= "nfs_user_#{stat.uid}"
  group_map[stat.gid] ||= ["nfs_group_#{stat.gid}", replacement_gid + 1]
  username = user_map[stat.uid]
  groupname, newgid = group_map[stat.gid]

  execute "change-gid" do
    command "sed -e 's/:#{stat.gid}:\\([^:]\\+\\)$/:#{newgid}:\\1/' -ibak /etc/group"
    user "root"

    not_if "grep '#{groupname}:x:#{stat.gid}:' /etc/group"
  end

  user username do
    uid stat.uid
  end

  group groupname do
    gid stat.gid
    members [username]
  end
end

