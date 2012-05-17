# Introduction

The purpose of the rails cookbook is to help people generate a new rails project
in a completely isolated development environment using vagrant. Just copy over
the Vagrantfile and cookbooks, edit the config, run "vagrant up", and you'll
have a full rails stack ready in around 10 mins. You can choose to use any ruby
or rails version, but note that the cookbook only supports rails 3 and above.

The rails recipe does make some assumptions about what technologies you'll be
using for your rails stack (haml, rspec, etc.). Feel free to edit the recipes if
you'd prefer to use others. You will be able to choose between two databases
technologies (mysql and postgresql). More choices may be implemented in future.

# Install

## Step 0 - Make sure Virtualbox and vagrant are installed:

Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
and [vagrant](http://vagrantup.com/)

## Step 1 - Setup the project directory:

`````bash
$ mkdir /path/to/project_name
$ cp Vagrantfile /path/to/project_name/
$ cp -r cookbooks /path/to/project_name/
`````

## Step 2 - Edit the Vagrantfile:

`````bash
$ cd /path/to/project_name
`````

Edit the Vagrantfile, replacing the app name on these two lines:
````ruby
   => vm.name = "My App"
   => :rails => { :app_name => "my_app",
````

Feel free to edit other options such as "db_type" ("mysql" or "postgresql"),
ruby version, and rails version. You can also up the memory or change the VM
IP address.

## Step 3 - Provision the box:

`````bash
$ vagrant up
````

The first time you use the cookbook it will probably take some extra time to
download the base box.

# Usage

You run code inside the virtual machine (which currently runs Ubuntu 12.04 LTS).
Use "vagrant ssh" to ssh into the VM.

You'll want to spin up a development web server inside the VM (you could also
install another web server such as unicorn or puma by installing the gem inside
the VM):

`````bash
$ vagrant ssh
$ cd /vagrant/my_app
$ bundle exec rails s
````

You can edit the code and manage your git repo outside of the VM. The project
directory will automatically sync with the /vagrant directory inside the VM.

Visit [http://vagrantup.com/](http://vagrantup.com/) for more instructions on how to use vagrant.
