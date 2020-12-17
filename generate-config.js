const fs = require('fs');
const YAML = require('yaml');

const configFileName = 'config.yml';

console.info(`Generating ${configFileName}...`);

const sitesConfig = require('./sites.json');

const vvvConfig = {
  sites: {},
  utilities: {
    core: [
      'tls-ca',
      'phpmyadmin',
      'memcached-admin',
      'opcache-status',
      'tideways',
      'webgrind',
      'mongodb',
      'php73',
      'php74',
    ],
    pmc: [
      'coretech',
      // 'dev-tools',
      'http-concat',
      'phpcs',
    ],
  },
  'utilities-sources': {
    pmc: {
      repo: 'git@github.com:penske-media-corp/pmc-vvv-utilities.git',
      branch: 'main',
    },
  },
  'vm_config': {
    memory: 4096,
    cores: 3,
  },
  general: {
    'db_backup': true,
    'db_restore': true,
    'db_share': false,
  },
  'vagrant-plugins': {
    disksize: '65GB',
  },
};

Object.entries(sitesConfig).forEach(
  (entry) => {
    const liveUrl = entry[0];
    const config = entry[1];

    if (! config.theme_repo) {
      console.warn(` - Skipping ${liveUrl} due to misconfiguration`);
      return;
    }

    if (! config.theme_slug) {
      config.theme_slug = '';
    }

    if (! config.provisioner_url) {
      config.provisioner_url = 'git@github.com:penske-media-corp/pmc-vvv-site-provisioners.git';
    }

    if (! config.provisioner_branch) {
      config.provisioner_branch = 'main';
    }

    if (! config.parent_theme_slug) {
      config.parent_theme_slug = '';
    }

    if (! config.grandchild_theme_repo) {
      config.grandchild_theme_repo = '';
    }

    if (! config.theme_dir_uses_vip) {
      config.theme_dir_uses_vip = false;
    }

    const slugifiedUrl = liveUrl.replace(/\./g,'-');

    vvvConfig.sites[slugifiedUrl] = {
      skip_provisioning: true,
      description: liveUrl,
      repo: config.provisioner_url,
      branch: config.provisioner_branch,
      hosts: [
        `${slugifiedUrl}.test`,
      ],
      custom: {
        live_url: `https://${liveUrl}`,
        site_title: `${config.site_title_prefix} (LOCAL)`,
        admin_user: 'pmcdev',
        admin_password: 'pmcdev',
        pmc: {
          theme_repo: config.theme_repo,
          theme_slug: config.theme_slug,
          parent_theme_slug: config.parent_theme_slug,
          grandchild_theme_repo: config.grandchild_theme_repo,
          theme_dir_uses_vip: config.theme_dir_uses_vip,
        }
      }
    };
  }
);

vvvConfig.sites['wordpress-trunk'] = {
  skip_provisioning: true,
  description: "An svn based WP Core trunk dev setup, useful for contributor days, Trac tickets, patches",
  repo: 'https://github.com/Varying-Vagrant-Vagrants/custom-site-template-develop.git',
  hosts: [
    'trunk.wordpress.test',
  ],
};

fs.writeFileSync(configFileName, YAML.stringify(vvvConfig));

console.info('Done!');
