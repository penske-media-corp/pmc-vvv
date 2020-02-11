# PMC-VVV

Welcome! This is the _in progress_ configuration for PMC's local WP development with VVV. This document should contain what you need to know for testing it out, but note that the following things are not yet ready to test:

* PHPUnit and PHPCS in the Vagrant machine (you can still run pipelines and these commands through Docker in each theme root)
* Setting up new WPCOM sites should be done manually - see below (adding new VIPGo sites is untested by the initial VVV testers)

To build a new PMC-VVV environment simply run `sh <(curl -s https://raw.githubusercontent.com/penske-media-corp/pmc-vvv/master/build-me-vvv.sh)` in your terminal and follow the prompts. If you have any issues please refer to the [VVV documentation](https://varyingvagrantvagrants.org/) or `#engineering` for questions. Engineering owns the evolution of this project and ops offers ultimate support of tooling. If you feel the urge to change something or find a bug the please submit a PR yourself.

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

* WPCOM: ``
* VIPGO: ``

### SQL dump

// todo 

* Where to get a SQL dump
* Importing a SQL dump

## Troubleshooting

Things may not go perfectly as you setup your environment. This section contains troubleshooting tips, and if your issue is not here, please contribute with what it was and how you solved it!

### WordPress Errors

When provisioning sites for the first time, you may encounter several WordPress errors. These will most likely be from the theme, due to lack of local data, but some are mysterious errors likely to do with caching. 

The following steps may help to reduce initial WordPress errors:

* Save theme menus
* Save theme options
* Inside the Vagrant command line, cycle (i.e. turn on/off) X Debug and memcache with the following: 
    1. `xdebug_on && xdebug_off`
    2. `sudo service memcached restart`

\* Note: phrases like "run them in the Vagrant machine" refer to the CLI after `vagrant ssh` is run from the root of the VVV directory.

### Miscellaenous

#### 2/11/2020

Error: ` Failed to start The PHP 7.2 FastCGI Process Manager.` during provisioning and 502 Bad Gateway error in HTTP response.
Fix: Update VVV to latest version and `vagrant reload --provision`. See [this Github issue](https://github.com/Varying-Vagrant-Vagrants/VVV/issues/2061#issuecomment-583557584) for futher troubleshooting.