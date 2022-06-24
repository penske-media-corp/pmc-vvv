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
