# PMC-VVV

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

See a list of the available sites [here for WPCOM](https://github.com/penske-media-corp/pmc-vvv/blob/master/config.yml#L6). VIPGo sites are also in that config file – search the brand you are looking for and refer to the entry in the `hosts` object e.g. `pmc-rollingstone-2018.test`.

Log in to the WordPress admin on any site with the following credentials:

* WPCOM: admin / password
* VIPGo: pmcdev / pmcdev

You may see a lot of WordPress errors. Refer to the troubleshooting notes below.

## Adding a New Site

// todo: steps for doing this

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
