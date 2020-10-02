#!/usr/bin/env bash

set -eo pipefail

# We need this script to bind mount various folder
# avoid using symlink where wordpress may not work properly with symlink.
#
# VIP Go
# wp-content/plugins/pmc-plugins -> coretech/pmc-plugins
# wp-content/themes/pmc-core-v2 -> coretech/pmc-core-v2
# wp-content/themes/vip/pmc-core-v2 -> coretech/pmc-core-v2
#
# VIP Classic
# wp-content/themes/vip/pmc-plugins -> coretech/pmc-plugins
# wp-content/themes/vip/pmc-core-v2 -> coretech/pmc-core-v2
#
# If share code is enabled, the following structures are used
#
# VIP Go
# wp-content/plugins/pmc-plugins -> coretech/pmc-plugins
# wp-content/themes/pmc-core-v2 -> coretech/pmc-core-v2
# wp-content/themes/vip/pmc-core-v2 -> coretech/pmc-core-v2
# wp-content/themes -> pmc_shared/wp-themes
#
# VIP Classic
# wp-content/themes/vip -> pmc_shared/wp-themes
# wp-content/themes/vip/pmc-plugins -> coretech/pmc-plugins
# wp-content/themes/vip/pmc-core-v2 -> coretech/pmc-core-v2
#
# @TODO
# public_html/wordpress -> /srv/src/wp-core/wordpress-[version]
# public_html/wp-tests/phpunit/includes -> /srv/src/wp-core/wp-tests-[version]/phpunit/includes
#

. "/srv/provision/provisioners.sh"

SITE=$1
SITE_ESCAPED="${SITE//./\\.}"
VM_DIR=$2
WP_VIP=$(get_config_value "sites.${SITE_ESCAPED}.custom.wp_vip" false)
PMC_SHARE_CORETECH_DIR=$(get_config_value "pmc.share.coretech_dir" "/srv/www/pmc/coretech")
PMC_SHARE_WP_THEMES_DIR=$(get_config_value "pmc.share.wp_themes_dir" '')

echo "Setup bind mount for site ${SITE}: ${WP_VIP}"

WP_CORE_DIR="${VM_DIR}/public_html"
WP_CONTENT_DIR="${WP_CORE_DIR}/wp-content"
WP_PLUGINS_DIR="${WP_CONTENT_DIR}/plugins"
WP_MU_PLUGINS_DIR="${WP_CONTENT_DIR}/mu-plugins"

function bind_mount() {
  local SOURCE=$1
  local TARGET=$2
  echo "bind mount: ${SOURCE} ${TARGET}"
  if [[ -n "$(mount | grep ${TARGET})" ]]; then
    umount ${TARGET}
  fi
  noroot mkdir -p ${SOURCE} ${TARGET}
  mount --bind ${SOURCE} ${TARGET}
}

function bind_mount_folders() {
  local SOURCE=$1
  local TARGET=$2
  local FOLDER
  for d in ${SOURCE}/*/; {
    FOLDER=$(basename "${d%/}")
    if [[ -n "${FOLDER}" &&  "*" != "${FOLDER}" && -d ${SOURCE}/${FOLDER} ]]; then
      bind_mount "${SOURCE}/${FOLDER}" "${TARGET}/${FOLDER}"
    fi
  }
}

# IMPORTANT: We need to bind the themes folder first,
# otherwise the pmc-core-v2 or pmc-plugins won't bind properly

if [[ -n "${PMC_SHARE_WP_THEMES_DIR}" ]]; then
  if [[ "${WP_VIP}" =~ go ]]; then
    bind_mount_folders ${PMC_SHARE_WP_THEMES_DIR} ${WP_CONTENT_DIR}/themes
  elif [[ "${WP_VIP}" =~ classic ]]; then
    bind_mount_folders ${PMC_SHARE_WP_THEMES_DIR} ${WP_CONTENT_DIR}/themes/vip
  fi
fi

bind_mount ${PMC_SHARE_CORETECH_DIR}/pmc-core-v2 ${WP_CONTENT_DIR}/themes/vip/pmc-core-v2

if [[ "${WP_VIP}" =~ go ]]; then
  bind_mount ${PMC_SHARE_CORETECH_DIR}/pmc-plugins ${WP_PLUGINS_DIR}/pmc-plugins
  bind_mount ${PMC_SHARE_CORETECH_DIR}/pmc-core-v2 ${WP_CONTENT_DIR}/themes/pmc-core-v2
elif [[ "${WP_VIP}" =~ classic ]]; then
  bind_mount ${PMC_SHARE_CORETECH_DIR}/pmc-plugins ${WP_CONTENT_DIR}/themes/vip/pmc-plugins
fi

provisioner_success