# PMC-VVV

> ⚠️
> 
> **This repository is deprecated.** PMC no longer supports VVV, but this 
> repository persists as a reference.

Configuration repo for PMC's use of VVV.

VVV is an open source local development environment designed for WordPress 
developers, and is used for both working on WordPress sites and contributing to 
WordPress Core.

This repo holds both a complete `config.yml` for VVV as well as the tools to 
update it as the configuration changes or sites are added. For more 
information, see the [Related repos](#related-repos) section.

## Documentation

* [Installing `pmc-vvv`](./docs/installing.md)
* [FAQ](./docs/faq.md)
* [Unit testing in individual sites](./docs/unit-tests.md)
* [Miscellaneous issues](./docs/misc-issues.md)

## Default WordPress Login

Username: `pmcdev`

Password: `pmcdev`

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
        "theme_dir_uses_vip": false,
        "php_version": 8.0
      }
      ```

      Notes:
      * `theme_slug` is optional. When omitted, the theme repo's slug is used;
        in the above example, the slug would be `pmc-spark`.
      * `theme_dir_uses_vip` defaults to `false` and can be omitted unless set
        `true`.
1. If necessary, run `npm install`.
1. Run `npm run build`.
1. Commit the `sites.json` and `config.yml` changes.
