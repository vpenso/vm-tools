
This section introduces methods to configure a virtual machine instance using the [Chef](https://www.chef.io/) Configuration Management System.

It is assumed that the **[chef-client](https://downloads.chef.io/chef) is installed in the virtual machine** image/instance already.

# Chef

The ↴ [chef-instance](../bin/chef-instance) program uploads cookbook, roles, and data-bags to the virtual machine instance before executing the `chef-client`:

* The path to Chef cookbooks is defined by the environment variable **`CHEF_COOKBOOKS`**.
* The programs [ssh-instance](../bin/ssh-instance) and [rsync-instance](../bin/rsync-instance) are used internally.

The following example uses the Chef [base](https://github.com/vpenso/chef-base) cookbook.

```bash
>>> git clone https://github.com/vpenso/chef-base ~/chef/cookbooks/base
# define the search paths for Chef cookbooks
>>> export CHEF_COOKBOOKS=~/chef/cookbooks:~/chef/site-cookbooks
# change to the directory of a virtual machine instance
>>> vm cd lxdev01
# configure the Chef cookbooks and roles to use 
>>> chef-instance cookbook base
>>> chef-instance role ~/projects/chef/cookbooks/base/test/roles/apt.rb
# execute chef-solo in the virtual machine instance
>>> chef-instance solo -r "role[ssh]"
```

All **configurations required by Chef** are available in the directory of the virtual machine instance:

* The `cookbooks/`, `roles/`, and `data-bags/` sub-directories contain the required files (or links to them).
* The files `chef_config.rb`, and `chef_attributes.json` include the configuration for `chef-client`.

```bash
├── chef_attributes.json
├── chef_config.rb
├── cookbooks
│   └── base -> ~/projects/chef/cookbooks/base
├── data-bags
├── disk.img
├── keys
│   ├── id_rsa
│   └── id_rsa.pub
├── libvirt_instance.xml
├── roles
│   └── apt.rb -> ~/projects/chef/cookbooks/base/test/roles/apt.rb
├── ssh_config
└── sync.log
```

The `chef-instance` command executes `chef-solo` in the virtual machine instance the following way:

```bash
>>> rsync-instance "cookbooks roles data-bags chef_*" :/var/tmp/chef 2>&1 1>>sync.log
>>> ssh-instance -s "chef-solo -c /var/tmp/chef/chef_config.rb -j /var/tmp/chef/chef_attributes.json"
```

