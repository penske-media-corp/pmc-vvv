#!/usr/bin/env bash

set -eo pipefail

. "/srv/provision/provisioners.sh"
function get_config_value() {
  local value=$(shyaml get-value "sites.${SITE_ESCAPED}.custom.${1}" 2> /dev/null < ${VVV_CONFIG})
  echo "${value:-$2}"
}
function get_primary_host() {
  local value=$(shyaml get-value "sites.${SITE_ESCAPED}.hosts.0" 2> /dev/null < ${VVV_CONFIG})
  echo "${value:-$1}"
}

SITE=$1
SITE_ESCAPED="${SITE//./\\.}"
VM_DIR=$2
VVV_PATH_TO_SITE=${VM_DIR} # used in site templates
VVV_SITE_NAME=${SITE}

echo " * Test Suite provisioner ${VVV_SITE_NAME}"

DOMAIN=$(get_primary_host "${VVV_SITE_NAME}".test)
SITE_TITLE=$(get_config_value 'site_title' "${DOMAIN}")
WP_VERSION=$(get_config_value 'wp_version' 'latest')
DB_NAME=$(get_config_value 'db_name' "${VVV_SITE_NAME}")
DB_NAME="${DB_NAME//[\\\/\.\<\>\:\"\'\|\?\!\*]/}"

WP_CORE_DIR="${VVV_PATH_TO_SITE}/public_html"

install_test_suite() {

  WP_TESTS=$(get_config_value 'wp_tests.provision' false | awk '{print tolower($0)}')
  if [ "${WP_TESTS}" != "true" ]; then
    WP_TESTS=$(get_config_value 'wp_tests' false | awk '{print tolower($0)}')
    if [ "${WP_TESTS}" != "true" ]; then
      return 0
    fi
  fi
  WP_TESTS_VERSION=${WP_VERSION}
  WP_TESTS_DATA=$(get_config_value 'wp_tests.data' false | awk '{print tolower($0)}')
  WP_TESTS_DB_NAME=$(get_config_value 'wp_tests.db_name' "${DB_NAME}_tests")
  WP_TESTS_DIR=$(get_config_value 'wp_tests.dir' "${VVV_PATH_TO_SITE}/wp-tests")
  WP_TESTS_CONFIG="${WP_TESTS_DIR}/wp-tests-config.php"

  if [[ "nightly" == "${VERSION}" || "trunk" == "${WP_TESTS_VERSION}" ]]; then
    WP_TESTS_TAG="trunk"
  elif [[ "latest" == "${WP_TESTS_VERSION}" ]]; then
    WP_TESTS_VERSION=$( curl -s http://api.wordpress.org/core/version-check/1.7/ | awk 'match($0, /"version":"([^"]+)"/, v) { print v[1]}' )
    if [[ -n "${WP_TESTS_VERSION}" ]]; then
      WP_TESTS_TAG="tags/${WP_TESTS_VERSION}"
    fi
  else
    WP_TESTS_TAG="tags/${WP_TESTS_VERSION}"
  fi

  if [[ -n "${WP_TESTS_TAG}" ]]; then

    if [[ ! -d ${WP_TESTS_DIR}/phpunit/includes ]]; then
      echo " * Installing Wordpress Tests ${WP_TESTS_VERSION} ${WP_TESTS_DIR}"
      noroot svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/includes ${WP_TESTS_DIR}/phpunit/includes
      if [[ "true" == "${WP_TESTS_DATA}" ]]; then
        noroot svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/data/ ${WP_TESTS_DIR}/phpunit/data
      fi
    else
      echo " * Updating Wordpress Tests ${WP_TESTS_VERSION} ${WP_TESTS_DIR}"
      noroot svn up ${WP_TESTS_DIR}/phpunit/includes
      if [[ "true" == "${WP_TESTS_DATA}" ]]; then
        noroot svn up ${WP_TESTS_DIR}/phpunit/data
      fi
    fi

    noroot svn --force export https://develop.svn.wordpress.org/${WP_TESTS_TAG}/wp-tests-config-sample.php ${WP_TESTS_DIR}/wp-tests-config.php

    sed \
      -e "s|dirname( __FILE__ ) . '/src/'|'${WP_DIR}/'|" \
      -e "s|Test\ Blog|${SITE_TITLE}|" \
      -e "s|admins@example\.org|${ADMIN_EMAIL}|" \
      -e "s|example\.org|${DOMAIN}|" \
      -e "s/youremptytestdbnamehere/${WP_TESTS_DB_NAME}/" \
      -e "s/yourpasswordhere/wp/" \
      -e "s/yourusernamehere/wp/" \
      -i ${WP_TESTS_CONFIG}

    echo -e " * Creating database '${WP_TESTS_DB_NAME}' (if it's not already there)"
    mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS \`${WP_TESTS_DB_NAME}\`"
    echo -e " * Granting the wp user privileges to the '${WP_TESTS_DB_NAME}' database"
    mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON \`${WP_TESTS_DB_NAME}\`.* TO wp@localhost IDENTIFIED BY 'wp';"
    echo -e " * DB operations done."

  fi

}

install_test_suite

echo " * Test Suite provisioner script completed for ${VVV_SITE_NAME}"

provisioner_success