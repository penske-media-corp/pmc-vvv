# Installing `pmc-vvv`

## Prerequisites
If you're the proud recipient of an M1, M1 Pro, or M1 Max machine follow [M1 Prerequisites](#m1-prerequisites) below.

### Intel Prerequisites

1. Install [VirtualBox](https://www.virtualbox.org/)
    - **Note for macOS 10.14 and above:** Due to updated security controls in macOS, VirtualBox will not install correctly unless you add Oracle's Developer ID to `spctl`.
        -  `spctl` is a command-line interface to the same security assessment policy subsystem that Gatekeeper uses. Like Gatekeeper, `spctl` will only accept Developer ID-signed apps and apps downloaded from the Mac App Store by default. It will reject apps signed with Mac App Store development or distribution certificates.
        - The next step involved rebooting your computer and typing commands in 
       the terminal when you can't access the internet or filesystem. Print or write down the following instructions.
    - Reboot into recovery mode (reboot and hold `Command` and `R` until the Apple logo appears, then release). Then open the Terminal (Utilities menu > Terminal) and type:
   ```bash
      $ spctl kext-consent add VB5E2TV963
      $ reboot
   ```
    - After reboot, install VirtualBox as normal and follow the instructions for enabling it via the Security & Privacy settings tab.

### M1 Prerequisites

1. Install [Parallels Pro](https://www.parallels.com/products/desktop/pro/) or the [Parallels Business Edition](https://www.parallels.com/products/business/). You can leverage the free trial to confirm everything is working, but it does require that you sign up and log into parallels on your machine to "activate" Pro features that are required to use Vagrant/VVV.
1. Install the open source [Vagrant Parallels Provider](https://github.com/Parallels/vagrant-parallels):
   ``` bash
   $ vagrant plugin install vagrant-parallels
   ``` 

**NOTE:** For M1 Machines, makes sure to checkout to the `develop` branch 
rather than the main brach in VVV. Parallels support is currently in beta (as of 4/7/2022).

## Install

### Install Vagrant & VVV
1. Install [Vagrant](https://www.vagrantup.com/)
1. Install VVV by following the "Installing VVV" steps here: 
   https://varyingvagrantvagrants.org/docs/en-US/installation/#installing-vvv.

### Authentication Prep
Provisioning requires SSH access to both Bitbucket and GitHub. Your host machine must share your SSH key with VVV using `ssh-agent` (aka key forwarding).

``` bash
$ ssh-keygen
```

Hit enter to each question. For both Bitbucket and Github add your SSH keys
to their respective site options.
- [Bitbucket SSH Docs](https://support.atlassian.com/bitbucket-cloud/docs/set-up-an-ssh-key/)
- [Github SSH Docs](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

Add your private SSH key to the `ssh-agent` **on your host machine**:
```bash
$ ssh-add -K [PATH TO YOUR PRIVATE KEY]
# e.g. ssh-add -K /Users/pmcjames/.ssh/id_rsa
```

For newer macOS version:
```bash
$ ssh-add --apple-use-keychain [PATH TO YOUR PRIVATE KEY]
# e.g. ssh-add --apple-use-keychain /Users/pmcjames/.ssh/id_rsa
```

### Configs
- Copy `config.yml` from this repo to the `config` directory in your VVV install, i.e. `~/VVV/config/config.yml`.
    - Within the copied `config.yml`, enable the site or sites you need by changing the site's `skip_provisioning`
      value to `false`. By default, no sites are provisioned, allowing each
      developer to install only the sites they work on. Each site takes
      approximately 3.5 minutes to provision.
    - If desired, add optional PMC utilities to the `utilities.pmc` array towards
      the end of the copied `config.yml`.
    - Towards the bottom of the copied `config.yml`,
      you may adjust the `vm_config` and `disksize` values if needed,
      such as when working with databases from some of our larger sites.
    - To change the version of PHP used by a particular site, add the
      following to a site's section in `config.yml`:
      ```yaml
      nginx_upstream: php80
      ```
      Replace `80` with the version number of the PHP you want to use,
      omitting the period.

### Provision
Provision Vagrant (i.e. install dependencies for the first time) as usual:

```bash
$ vagrant up --provision
```

Note that at any time in the future, you can change which sites are provisioned
and run `vagrant provision` to create the new sites. VVV does not remove sites
that were previously provisioned, but it does remove the site's hosts entry,
restricting access to only WP-CLI.

## HTTPS (SSL)

To match production, all local environments are configured to use HTTPS URLs.
Browsers will display certificate errors after you first provision VVV.

To fix these errors, see VVV's instructions [here](https://varyingvagrantvagrants.org/docs/en-US/references/https/trusting-ca/).
