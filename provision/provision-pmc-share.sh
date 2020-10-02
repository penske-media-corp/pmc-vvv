#!/usr/bin/env bash

set -eo pipefail

. "/srv/provision/provisioners.sh"
provisioner_begin "pmc-share"

SKIP_PROVISION=$(get_config_value "pmc.share.skip_provisioning")
if [[ -n "${SKIP_PROVISION}" && "true" == "${SKIP_PROVISION}" ]]; then
  exit
fi

PMC_SHARE_WP_CORE_DIR=$(get_config_value "pmc.share.wp_core_dir" "/srv/src/wp-core")
PMC_SHARE_WP_VERSION=$(get_config_value "pmc.share.wp_version" "5.4")

WP_CORE_DIR="${PMC_SHARE_WP_CORE_DIR}/wordpress"
WP_CONTENT_DIR="${WP_CORE_DIR}/wp-content"
WP_PLUGINS_DIR="${WP_CONTENT_DIR}/plugins"
WP_MU_PLUGINS_DIR="${WP_CONTENT_DIR}/mu-plugins"
WP_TESTS_DIR="${PMC_SHARE_WP_CORE_DIR}/wp-tests"
WP_TESTS_CONFIG="${WP_TESTS_DIR}/phpunit/wp-tests-config.php"
WP_TESTS_DB_NAME="wp_tests"

if [[ "latest" == "${PMC_SHARE_WP_VERSION}" ]]; then
  WP_VERSION=$( curl -s http://api.wordpress.org/core/version-check/1.7/ | awk 'match($0, /"version":"([^"]+)"/, v) { print v[1]}' )
else
  WP_VERSION="${PMC_SHARE_WP_VERSION}"
fi

if [[ ! -d ${WP_CORE_DIR} ]]; then
  echo " * Installing Wordpress  ${WP_VERSION} ${WP_CORE_DIR}"
  curl -sL https://wordpress.org/wordpress-${WP_VERSION}.tar.gz | noroot tar -zx --directory ${PMC_SHARE_WP_CORE_DIR}
  if [[ "${PMC_SHARE_WP_CORE_DIR}/wordpress" != "${WP_CORE_DIR}" ]]; then
    noroot mv ${PMC_SHARE_WP_CORE_DIR}/wordpress ${WP_CORE_DIR}
  fi
  echo " * Wordpress installed"
fi

if [[ ! -d ${WP_TESTS_DIR}/phpunit/includes ]]; then
  echo " * Installing Wordpress Tests ${WP_VERSION} ${WP_TESTS_DIR}"
  noroot svn co --quiet https://develop.svn.wordpress.org/tags/${WP_VERSION}/tests/phpunit/includes ${WP_TESTS_DIR}/phpunit/includes
  noroot svn --force export https://develop.svn.wordpress.org/tags/${WP_VERSION}/wp-tests-config-sample.php ${WP_TESTS_CONFIG}

  sed \
    -e "s|dirname( __FILE__ ) . '/src/'|'${WP_CORE_DIR}/'|" \
    -e "s/youremptytestdbnamehere/${WP_TESTS_DB_NAME}/" \
    -e "s/yourpasswordhere/wp/" \
    -e "s/yourusernamehere/wp/" \
    -i ${WP_TESTS_CONFIG}

  echo -e " * Creating database '${WP_TESTS_DB_NAME}' (if it's not already there)"
  mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS \`${WP_TESTS_DB_NAME}\`"
  echo -e " * Granting the wp user priviledges to the '${WP_TESTS_DB_NAME}' database"
  mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON \`${WP_TESTS_DB_NAME}\`.* TO wp@localhost IDENTIFIED BY 'wp';"
  echo -e " * DB operations done."

  echo " * Wordpress Tests installed."
fi

provisioner_success