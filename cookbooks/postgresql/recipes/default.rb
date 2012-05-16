require_recipe "apt"

package "python-software-properties"
execute "add-apt-repository ppa:pitti/postgresql"
execute "apt-get update"

package "postgresql-9.1"
package "postgresql-client"
