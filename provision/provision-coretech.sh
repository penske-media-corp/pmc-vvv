#!/usr/bin/env bash

set -eo pipefail

. "/srv/provision/provisioners.sh"

provisioner_begin "coretech"

PMC_SHARE_CORETECH_DIR=$(get_config_value "pmc.share.coretech_dir" "/srv/www/pmc/coretech")
PMC_SHARE_PHP_VERSION=$(get_config_value "pmc.share.php_version" "7.3")

function git_checkout {
  local TARGET=${1}
  local SOURCE=${2}

  if [[ -z "${TARGET}" ]]; then
    exit 1
  fi
  if [[ -z "${SOURCE}" ]]; then
    exit 1
  fi

  if [ ! -d ${TARGET} ]
  then
    noroot mkdir -p ${TARGET}
  fi

	echo "Git checkout: ${SOURCE} ${TARGET}"

	local OLD_PATH="$(pwd)"
	cd ${TARGET}

  if [ ! -d ${TARGET}/.git ]; then
    noroot git clone ${SOURCE} .
  else
    noroot git pull
  fi

  cd ${OLD_PATH}

}

if [ -f /usr/bin/php${PMC_SHARE_PHP_VERSION} ]; then
	update-alternatives --set php /usr/bin/php${PMC_SHARE_PHP_VERSION}
	update-alternatives --set phar /usr/bin/phar${PMC_SHARE_PHP_VERSION}
	update-alternatives --set phar.phar /usr/bin/phar.phar${PMC_SHARE_PHP_VERSION}
	update-alternatives --set phpize /usr/bin/phpize${PMC_SHARE_PHP_VERSION}
	update-alternatives --set php-config /usr/bin/php-config${PMC_SHARE_PHP_VERSION}
fi

git_checkout ${PMC_SHARE_CORETECH_DIR}/pmc-plugins git@bitbucket.org:penskemediacorp/pmc-plugins.git
git_checkout ${PMC_SHARE_CORETECH_DIR}/pmc-core-v2 git@bitbucket.org:penskemediacorp/pmc-core-v2.git

git_checkout ${PMC_SHARE_CORETECH_DIR}/pmc-codesniffer git@bitbucket.org:penskemediacorp/pmc-codesniffer.git
cd ${PMC_SHARE_CORETECH_DIR}/pmc-codesniffer
noroot composer install --no-autoloader
noroot composer depends squizlabs/php_codesniffer

ln -sf ${PMC_SHARE_CORETECH_DIR}/pmc-codesniffer/vendor/squizlabs/php_codesniffer/bin/phpcbf /usr/local/bin/
ln -sf ${PMC_SHARE_CORETECH_DIR}/pmc-codesniffer/vendor/squizlabs/php_codesniffer/bin/phpcs /usr/local/bin/
chmod +x /usr/local/bin/*
noroot phpcs --config-set default_standard PmcWpVip

if [[ -z "$(grep "self::getConfigData('show_sources')" vendor/squizlabs/php_codesniffer/src/Config.php)" ]]; then
	sed "/self::getConfigData('show_progress')/i\$showSources=self::getConfigData('show_sources');if(\$showSources!==null){\$this->showSources=(bool)\$showSources;}"  -i vendor/squizlabs/php_codesniffer/src/Config.php
	echo "Patched phpcs"
fi
phpcs --config-set show_sources 1

provisioner_success