# FAQ

## Where are the errors?

VVV is configured to write the `WP_DEBUG` log to `~/wp-content/debug.log` rather
than printing those messages to the screen.

This can be disabled on a per-site basis by changing the `WP_DEBUG_LOG` constant
to `false`.

## Single posts are redirecting to the homepage. What do I do?

Flush the rewrite rules in `wp-admin` under VIP > Dashboard > Rewrite Rules.

## I'm already using `pmc-vvv`. What's next?

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

## How do I switch PHP versions?

### If your `config.yml` does not include the desired PHP version in the `utilities.core` section:

1. Add it there, e.g. `php80` or `php81`.
1. For sites you wish to switch to the new version, update the
   `nginx_upstream` in the site's configuration to match the desired version, e.g. `php80`.
1. Run `vagrant provision`.

### If you've already provisioned the new PHP version:

#### Via `vagrant provision`:

1. Update the `nginx_upstream` in the site's section of `config.yml` to match  the desired version, e.g. `php80`.
1. Run `vagrant provision`.

#### Without re-provisioning:

1. `vagrant ssh` and change to the `/etc/nginx/custom-sites` directory.
1. Run `ls -la` and find the filename of the site you wish to update. It  will be in the format of `vvv-[SITE_SLUG]-[HASH].conf`.
1. Use the `sudo` command to edit the file identified in the previous step, e.g. `sudo vim` or `sudo nano`.
1. Find the line that's preceded by the comment `# This is needed to set the PHP being used`.
1. At the end of the following line, change the specified PHP version to the  desired version.

   For example, if the line was:

   ```set          $upstream php74;```

   And you want to set the site to PHP 8.0, change it to:

   ```set          $upstream php80;```
1. Save the file and exit the editor.
1. Restart nginx by running `sudo /etc/init.d/nginx restart`.

### Using a different PHP version with WP-CLI:

Note that switching an individual site's PHP version applies only to the web server, but does not affect the PHP version used by WP-CLI. Additionally, the `WP_CLI_PHP` environment variable has no effect on the PHP version used by the copy of WP-CLI installed in the VM.

To run WP-CLI with a different PHP version, such as PHP 8.0:

```bash
/usr/bin/php8.0 /usr/local/bin/wp [COMMAND]
```

The two available PHP versions, and their paths, are:
* 8.0: `/usr/bin/php8.0`
* 8.1: `/usr/bin/php8.1`

To confirm which PHP version is used by WP-CLI, run:

```bash
/usr/bin/php8.0 /usr/local/bin/wp cli info
```

Confirm that the `PHP version` and `php.ini used` lines reference the
expected version.


### PHPUNIT with PHP 8:

First, make sure you have php 8 installed ([see above in the FAQ](#if-your-configyml-does-not-include-the-desired-php-version-in-the-utilitiescore-section)).

The steps to install are in the [unit testing docs](../docs/unit-tests.md). PHP8 requires us to use PHPUnit 9, which requires us to use the WordPress 6 test suite and add the yoast/phpunit-polyfills. They are very similar to how phpunit7 was installed, but you should still follow them from the beginning as you are installing new versions of phpunit and the wordpress test suite, as well as a new composer package.

Any time you are using a specific version of php to run a command, you need the full path, i.e. `php8.0 /usr/local/bin/composer ...` instead of just `php8.0 composer ...`.

You can keep your existing theme wp-tests-config.php, but you will need to add a new constant: `define('WP_TESTS_PHPUNIT_POLYFILLS_PATH', '/home/vagrant/vendor/yoast/phpunit-polyfills/');`
