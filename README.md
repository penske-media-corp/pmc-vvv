# PMC-VVV

Configuration repo for PMC's use of VVV

This repo holds both a complete `config.yml` for VVV as well as the tools to
update it as the configuration changes or sites are added.

## Prerequisites

1. [Virtualbox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/)
1. A checkout of [VVV](https://github.com/Varying-Vagrant-Vagrants/vvv)
1. SSH key forwarding via `ssh-agent` (see [below](#ssh-agent))

### `ssh-agent`

Provisioning requires SSH access to both Bitbucket and GitHub; neither username
and password nor applications passwords are supported.

It is not, however, necessary to add your private key to VVV. Instead, your host
machine must share it with VVV using `ssh-agent` (aka key forwarding).

To do so:

1. Add your public SSH key to your Bitbucket and GitHub accounts.
1. Add your private SSH key to the `ssh-agent` **on your host machine**:
   ```bash
   ssh-add -K [PATH TO YOUR PRIVATE KEY]
   ```

## Using with VVV

1. Install Vagrant plugins:
   ```bash
   $ vagrant plugin install vagrant-hostsupdater vagrant-disksize vagrant-scp
   ```
1. Copy `config.yml` to the `config` directory in your VVV install, typically
   `~/vvv/config/`.
1. Enable the site or sites you need by changing the site's `skip_provisioning`
   value to `false`. By default, no sites are provisioned, allowing each
   developer to install only the sites they work on. Each site takes
   approximately 3.5 minutes to provision.

   1. Enable the `wordpress-trunk` site if you plan to run PHPUnit in VVV
      instead of Docker.

      **Note** that it requires manual configuration, such as installing our
      shared plugins and any theme code to be tested.
1. If desired, add optional PMC utilities to the `utilities.pmc` array towards
   the end of the configuration.
1. Adjust the `vm_config` and `disksize` values if needed, such as when working
   with databases from some of our larger sites.

Note that at any time in the future, you can change which sites are provisioned
and run `vagrant provision` to create the new sites. VVV does not remove sites
that were previously provisioned, but it does remove the site's hosts entry,
restricting access to only WP-CLI.

## HTTPS (SSL)

To match production, all local environments are configured to use HTTPS URLs.
Browsers will display certificate errors after you first provision VVV.

To fix these errors, see VVV's instructions at
https://varyingvagrantvagrants.org/docs/en-US/references/https/trusting-ca/.

## Default WordPress Login

Username: `pmcdev`

Password: `pmcdev`

## FAQ

### Where are the errors?

VVV is configured to write the `WP_DEBUG` log to `~/wp-content/debug.log` rather
than printing those messages to the screen.

This can be disabled on a per-site basis by changing the `WP_DEBUG_LOG` constant
to `false`.

### Single posts are redirecting to the homepage. What do I do?

Flush the rewrite rules in `wp-admin` under VIP > Dashboard > Rewrite Rules.

### I'm already using `pmc-vvv`. What's next?

There are several options for adopting the latest VVV configuration.

1. Start fresh:
   1. Run `vagrant destroy`
   1. Delete the VVV directory
   1. Check out VVV, drop in the new configuration, and provision
1. Migrate to a fresh instance:
   1. Run `vagrant destroy`
   1. Copy the database backups to a safe location (from `database/sql/backups`)
   1. Delete the VVV install and start anew
   1. Import the database backup and update URLs
      1. Copy the database backup to the new site's VVV folder
      1. Run `vagrant ssh` and change to the new site's directory
      1. Run `wp db import [FILE]`
      1. Run `wp search-replace [OLD URL] [NEW URL]`
      1. Flush the cache: `wp cache flush`
1. Set up a new VVV instance alongside your existing one. As long as both aren't
   running at the same time, they can coexist.
1. Retain sites set up using `build-me-vvv.sh` (**NOT RECOMMENDED**):
   1. Modify the generated config so that the site slug and host matches what's
      currently in use.
   1. Set the site to use the
      [default VVV provisioner](https://github.com/Varying-Vagrant-Vagrants/custom-site-template)
      rather than our custom one, pulling from the `master` branch
   1. Run `vagrant destroy` and `vagrant provision`

      The existing sites will remain, including the unused `wpcom.test` network,
      and you'll need to reconcile your updates with any future changes to the
      generated config, but this will retain all of your existing sites in case
      you have something set up that you cannot part with.

## Miscellaneous Issues
### 12/17/2020
Error: `git@github.com: Permission denied (publickey).fatal: Could not read from remote repository.` during provision pmc utilities (found in provisioner-utility-soucre-pmc.log)

Fix: Add key to ssh-agent using: `ssh-add -K [PATH_TO_PRIVATE_KEY]`
### 2/11/2020

Error: `Failed to start The PHP 7.2 FastCGI Process Manager.` during
provisioning and 502 Bad Gateway error in HTTP response.

Fix: Update VVV to latest version and `vagrant reload --provision`. See
[this Github issue](https://github.com/Varying-Vagrant-Vagrants/VVV/issues/2061#issuecomment-583557584)
for further troubleshooting.

## Related repos:

This configuration builds on two additional repositories, in keeping with the
patterns established by VVV. This should lower the maintenance burden by
leveraging as much of the open-source project as possible.

1. Utilities: https://github.com/penske-media-corp/pmc-vvv-utilities

   This repo contains all PMC modifications to VVV, such as installing our PHPCS
   standards and creating a local cache of shared code used during site
   provisioning.
1. Provisioners: https://github.com/penske-media-corp/pmc-vvv-site-provisioners

   This repo contains PMC's extensions of VVV's site provisioners. These
   leverage features added by our custom utilities and take the place of the
   build script that previously handled tasks like installing `pmc-plugins` and
   a site's theme(s).

## Updating `config.yml`

This repo includes a node script that generates `config.yml`. It handles the
boilerplate configuration while supporting the configuration options relevant
to PMC.

1. Update `sites.json` as needed.
   1. If adding a new site, its entry in the array should be keyed by the
      primary domain. The list is ordered alphabetically!

      Below is a configuration that illustrates the available options:
      ```json
      "example.com": {
        "site_title_prefix": "Example",
        "theme_repo": "git@bitbucket.org:penskemediacorp/pmc-spark.git",
        "theme_slug": "",
        "parent_theme_slug": "pmc-core-v2",
        "grandchild_theme_repo": "",
        "theme_dir_uses_vip": false
      }
      ```

      Notes:
      * `theme_slug` is optional. When omitted, the theme repo's slug is used;
        in the above example, the slug would be `pmc-spark`.
      * `grandchild_theme_repo` is optional and is used for international
        sites, such as Robb Report UK.
      * `theme_dir_uses_vip` defaults to `false` and can be omitted unless set
        `true`.
1. If necessary, run `npm install`.
1. Run `node generate-config.js`.
1. Commit the `sites.json` and `config.yml` changes.
