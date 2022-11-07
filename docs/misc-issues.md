# Miscellaneous Issues

## 10/27/22
Error: In PluginManager.php line 769:

  dealerdirect/phpcodesniffer-composer-installer contains a Composer plugin w
  hich is blocked by your allow-plugins config. You may add it to the list if

Fix: If provisioning fails, there’s a high chance it has already been fixed. Update your VVV to the newest version.

If updating to the latest version does not help, try the develop branch:

Switch to develop:

git checkout develop
Then make sure it’s the latest develop:

git pull
And reprovision:

vagrant up --provision


## 04/12/2022
Error: Unable to launch xdebug with Parallels.

Fix: Ensure that the pathMappings for your IDE are as follows: `"/srv/www/": "/Users/USERNAME/vvv-local/www/",`. And confirm that there are not two instances of `define( 'WP_DEBUG', true|false );` in the `wp-config.php` file for the site you're attempting to run xdebug for. In the `vvv-local/config/php-config/xdebug.ini` find or add the `xdebug.discover_client_host=` value and set it to `1` instead of `0`. Run `vagrant provision` to reprovision your local.

## 04/07/2022
Error: While running `vagrant up` the box will warn that `vagrant-goodhosts` plugin is not installed and will suggest `vagrant plugin install --local` will fix the issue. It does not.

Fix: Install the `vagrant-goodhosts` plugin manually. `vagrant plugin install vagrant-goodhosts` followed by `vagrant reload --provision` to ensure that all dependencies are in sync.

## 03/11/2021
Error: During `vagrant up --provision` encountered `default: sudo: unable to execute /usr/local/bin/wp: Permission denied`. Upon SSHing into Vagrant (`vagrant ssh`) noted with `ls -al /usr/local/bin/wp` that this wp-cli script was owned by `root` and within the group `root`.

Fix: While SSH'd into Vagrant, delete wp-cli with `rm /usr/local/bin/wp` then provision again. Afterwards, wp-cli was properly owned by `vagrant` user and within the `www-data` group.

## 12/17/2020
Error: `git@github.com: Permission denied (publickey).fatal: Could not read from remote repository.` during provision pmc utilities (found in provisioner-utility-soucre-pmc.log)

Fix: Add key to ssh-agent using: `ssh-add -K [PATH_TO_PRIVATE_KEY]`
## 2/11/2020

Error: `Failed to start The PHP 7.2 FastCGI Process Manager.` during
provisioning and 502 Bad Gateway error in HTTP response.

Fix: Update VVV to latest version and `vagrant reload --provision`. See
[this Github issue](https://github.com/Varying-Vagrant-Vagrants/VVV/issues/2061#issuecomment-583557584)
for further troubleshooting.

## 2021
An error during initial creation/provisioning on Macbook Pros.

```bash
VBoxManage: error: VBoxNetAdpCtl: Error while adding new interface: failed to open /dev/vboxnetctl: No such file or directory
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component HostNetworkInterfaceWrap, interface IHostNetworkInterface
```
The solution seems to be to restart your Mac laptop in Recovery mode (cmd + R), then open a Terminal and enter:
```bash
spctl kext-consent add VB5E2TV963
```
and restart. VB5E2TV963 is the Oracle developer ID.

## 10/11/2021
Updating the vagrant-goodhosts plugin to 1.0.18 causes the error `check_hostnames_to_add': undefined method each` during provisioning.
Goodhosts has acknowledged the error in this [this Github issue](https://github.com/goodhosts/vagrant/issues/40#issuecomment-940871327).
Rolling back to 1.0.17 or a later version with the fix should fix the issue.

## 12/30/2021
When provisioning, getting an SSH error:
```
The SSH command responded with a non-zero exit status. Vagrant assumes that this means the command failed.
```
This could be from a reboot on Mac OS which clears existing SSH keys. In that case, re-add the key with `ssh-add -K /path/to/private/key`
