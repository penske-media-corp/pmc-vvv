# PMC-VVV

Welcome! This is the new and still-in-progress-but-ready-to-use configuration for PMC's local WP development with VVV. This document should contain what you need to know for testing it out, but note that the following things are not yet ready to test:

* PHPUnit and PHPCS in the Vagrant machine (you can still run pipelines and these commands through Docker in each theme root)
* Setting up new WPCOM sites should be done manually - see below (adding new VIPGo sites is untested by the initial VVV testers)

To build a new PMC-VVV environment, first ensure you have the latest versions of [Vagrant](https://www.vagrantup.com/docs/installation) and [VirtualBox](https://www.virtualbox.org/) installed, then run `sh <(curl -s https://raw.githubusercontent.com/penske-media-corp/pmc-vvv/master/build-me-vvv.sh)` in your terminal in a directoty where you would like to install the environment (the script will create a directory `VVV`. Then follow the prompts.

If you have any issues please refer to the [VVV documentation](https://varyingvagrantvagrants.org/) or `#engineering` for questions. Engineering owns the evolution of this project and ops offers ultimate support of tooling. If you feel the urge to change something or find a bug the please submit a PR yourself.

## Build PMC-VVV

- `sh <(curl -s https://raw.githubusercontent.com/penske-media-corp/pmc-vvv/master/build-me-vvv.sh)`
  - If running for the first time:
    - Answer `1` to all prompts
  - If re-running the script:
    - You can skip the first two steps ( cloning VVV and copying the config )
    - Run from inside VVV directory
- When prompted for a password on git repositories enter an application password to clone repositories
- If at any time PMC-VVV fails to build or a site doesn't provision you can re-run/skip any of the steps in the go script

### After the Build

See a list of the available sites [here for WPCOM](https://github.com/penske-media-corp/pmc-vvv/blob/master/config.yml#L6). VIPGo sites are also in that config file – search the brand you are looking for and refer to the entry in the `hosts` object e.g. `pmc-rollingstone-2018.test`. All URLs are the theme names + `.test` for VIPGo and `.wpcom.test` for VIP Classic.

Log in to the WordPress admin on any site with the following credentials:

* WPCOM: admin / password
* VIPGo: pmcdev / pmcdev

You may see a lot of WordPress errors. Refer to the troubleshooting notes below.

## Adding a New Site

### VIP Classic (WPCOM)

Using the pmc-vvv script:

* Add the site to the `wpcom` and `hosts` object in config.yml.
* Run the pmc-vvv script, and skip all steps except "Setup WPCOM sites?"

The above may not work, in which case, do the following to manually add the WPCOM site:

* Clone the theme inside www/wpcom/public_html/wp-content/themes
* Run the following scripts to add the site (where pmc-variety-2020 is the name of the theme and thus the name of the site - they should be the same):
    * `wp site create --slug=pmc-variety-2020.wpcom.test --path=/srv/www/wpcom/public_html`
    * `wp theme activate pmc-variety-2020 --url=pmc-variety-2020.wpcom.test --path=/srv/www/wpcom/public_html`
* That should do it!

## Getting Local Data

### Theme WP-CLI Scripts

Check the theme for WP-CLI scripts (DL, AN, and VY 2020 should have them for setting up carousels) and run them in the Vagrant machine*.

### WXR

Export content from the QA site via the WordPress exporter, and import the WXR file (the file format of the WP export - stands for WordPress Extended RSS) via the WP admin or WP-CLI.

Importing from the admin will work for a small amount of posts, but you may get a memory limit error, so importing via WP-CLI is recommended. From inside the vagrant machine, run either of these commands:

// todo

* WPCOM: ``
* VIPGO: ``

### SQL dump

// todo

* Where to get a SQL dump

Once you have a SQL dump, make sure the site URL is updated in the SQL file.

`wp db import --path=/srv/www/wpcom/public_html --url=pmc-variety-2020.wpcom.test /srv/www/pmc.wp_2.sql`

## Troubleshooting

Things may not go perfectly as you setup your environment. This section contains troubleshooting tips, and if your issue is not here, please contribute with what it was and how you solved it!

### Installation or Provisioning Errors

An example of this error is a syntax error in the Vagrantfile (outdated Vagrant) or inability to successfully provision. Make sure you are running the latest versions of Vagrant and VirtualBox. If you have outdated Vagrant plugins, you may need to manually delete them before provisioning PMC-VVV with `vagrant plugin expunge`.

### WordPress Errors

When provisioning sites for the first time, you may encounter several WordPress errors. These will most likely be from the theme, due to lack of local data, but some are mysterious errors likely to do with caching.

The following steps may help to reduce initial WordPress errors:

* Save theme menus
* Save theme options
* Inside the Vagrant command line, cycle (i.e. turn on/off) X Debug and memcache with the following:
    1. `xdebug_on && xdebug_off`
    2. `sudo service memcached restart`

\* Note: phrases like "run them in the Vagrant machine" refer to the CLI after `vagrant ssh` is run from the root of the VVV directory.

### FAQ

#### Single posts are redirecting to the homepage. What do I do?

Flush the VIP rewrite rules in VIP > Dashboard > Rewrite Rules.

#### How can I enable Gutenberg on a site?

```
if ( function_exists( 'wpcom_vip_load_gutenberg' ) ) {
	wpcom_vip_load_gutenberg( true );
}
```

See [this doc from VIP](https://wpvip.com/documentation/vip-go/loading-gutenberg/).

#### Why isn't my Bitbucket password working for cloning repos?

With 2 factor authentication, you will need to create an App Password in Bitbucket at https://bitbucket.org/account/settings/app-passwords/

#### Load times are incredibly slow - how can I speed them up?

Increase the memory alotted to the virtual machine in Virtual Box > Settings > System. This seems to reset frequently.

With VVV we are signing up for a base level of slowness, but if the load times are 45 seconds or more, you might consider trashing your current environement and running the pmc-vvv script in a fresh directory.

### Miscellaenous Issues

#### 5/27/2020

A fresh install resulted in many instances of this warning on VIP Go sites:
```
Notice: wpcom_vip_load_plugin was called incorrectly. `wpcom_vip_load_plugin( pmc-global-functions, pmc-plugins )` was called after the `plugins_loaded` hook. For best results, we recommend loading your plugins earlier from `client-mu-plugins`. Please see Debugging in WordPress for more information. in /srv/www/pmc-indiewire-2016/public_html/wp-includes/functions.php on line 5167
```

We load our plugins differently than VIP expects, and they recently added that warning. The only solution at present is to turn off WP_DEBUG. See [this message from Hau with more detail](https://penskemediacorp.slack.com/archives/C0AN3PRLP/p1590607456193000?thread_ts=1590606873.190100&cid=C0AN3PRLP).

#### 2/11/2020

Error: ` Failed to start The PHP 7.2 FastCGI Process Manager.` during provisioning and 502 Bad Gateway error in HTTP response.
Fix: Update VVV to latest version and `vagrant reload --provision`. See [this Github issue](https://github.com/Varying-Vagrant-Vagrants/VVV/issues/2061#issuecomment-583557584) for futher troubleshooting.
