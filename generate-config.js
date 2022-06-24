const fs = require('fs');
const YAML = require('yaml');

const configFileName = 'config.yml';
const defaultPhpVersion = 7.4;

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
      'webgrind',
      'php73',
      'php74',
      'php80',
    ],
    pmc: [
      'coretech',
      // 'dev-tools',
      'http-concat',
      'phpcs',
    ],
  },
  'utility-sources': {
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
    const [ liveUrl, config ] = entry;

    if (! config.theme_repo) {
      console.warn(` - Skipping ${liveUrl} due to misconfiguration`);
      return;
    }

    const slugifiedUrl = liveUrl.replace(/\./g,'-');

    const phpVersion = parseFloat(config.php_version ?? defaultPhpVersion).toFixed(1);
    const nginxUpstream = `php${phpVersion}`.replace('.', '');

    vvvConfig.sites[slugifiedUrl] = {
      skip_provisioning: true,
      description: liveUrl,
      repo: config.provisioner_url ?? 'git@github.com:penske-media-corp/pmc-vvv-site-provisioners.git',
      branch: config.provisioner_branch ?? 'main',
      hosts: [
        `${slugifiedUrl}.test`,
      ],
      nginx_upstream: nginxUpstream,
      custom: {
        live_url: `https://${liveUrl}`,
        site_title: `${config.site_title_prefix} (LOCAL)`,
        admin_user: 'pmcdev',
        admin_password: 'pmcdev',
        pmc: {
          theme_repo: config.theme_repo,
          theme_slug: config.theme_slug ?? '',
          parent_theme_slug: config.parent_theme_slug ?? '',
          theme_dir_uses_vip: config.theme_dir_uses_vip ?? false,
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

YAML.scalarOptions.str.fold.lineWidth = 0;

fs.writeFileSync(configFileName, YAML.stringify(vvvConfig));

console.info('Done!');
