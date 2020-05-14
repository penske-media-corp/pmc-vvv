#!/usr/bin/env bash

# We need this script to bind mount various folder
# avoid using symlink where wordpress may not work properly with symlink.
#
# VIP Go
# wp-content/plugins/pmc-plugins -> /srv/www/pmc/coretech/pmc-plugins
# wp-content/themes/pmc-core-v2 -> /srv/www/pmc/coretech/pmc-core-v2
#
# VIP Classic
# wp-content/themes/vip/pmc-plugins -> /srv/www/pmc/coretech/pmc-plugins
# wp-content/themes/vip/pmc-core-v2 -> /srv/www/pmc/coretech/pmc-core-v2
#
# If share code is enabled, the following structures are used
#
# VIP Go
# wp-content/plugins/pmc-plugins -> /srv/wp-themes/pmc-plugins
# wp-content/themes -> /srv/wp-themes
# wp-content/themes/vip -> /srv/wp-themes
#
# VIP Classic
# wp-content/themes/vip -> /srv/wp-themes
#
# @TODO
# public_html/wordpress -> /srv/wp-core/wordpress-[version]
# public_html/wp-tests/phpunit/includes -> /srv/wp-core/wp-tests-[version]/phpunit/includes
#

SITE=$1
VM_DIR=$2
WP_VIP=$3
SHARE_CODE=$4

echo "Setup bind mount for site ${SITE}: ${WP_VIP}"

WP_CORE_DIR="${VM_DIR}/public_html"
WP_CONTENT_DIR="${WP_CORE_DIR}/wp-content"
WP_PLUGINS_DIR="${WP_CONTENT_DIR}/plugins"
WP_MU_PLUGINS_DIR="${WP_CONTENT_DIR}/mu-plugins"

function bind_mount() {
	local SOURCE=$1
	local TARGET=$2
	if [[ -n "$(mount | grep ${TARGET})" ]]; then
		umount ${TARGET}
	fi
	mkdir -p ${SOURCE} ${TARGET}
	mount --bind ${SOURCE} ${TARGET}
}

if [[ "true" == "${SHARE_CODE}" ]]; then

	SOURCE_THEMES_DIR=/srv/wp-themes

	if [[ "${WP_VIP}" =~ go ]]; then
		mount --bind ${SOURCE_THEMES_DIR}/pmc-plugins ${WP_PLUGINS_DIR}/pmc-plugins
		mount --bind ${SOURCE_THEMES_DIR} ${WP_CONTENT_DIR}/themes
		mount --bind ${SOURCE_THEMES_DIR} ${WP_CONTENT_DIR}/themes/vip
	elif [[ "${WP_VIP}" =~ classic ]]; then
		mount --bind ${SOURCE_THEMES_DIR} ${WP_CONTENT_DIR}/themes/vip
	fi

else

	SOURCE_PMC_CORETECH=/srv/www/pmc/coretech
	mount --bind ${SOURCE_PMC_CORETECH}/pmc-core-v2 ${WP_CONTENT_DIR}/themes/pmc-core-v2

	if [[ "${WP_VIP}" =~ go ]]; then
		mount --bind ${SOURCE_PMC_CORETECH}/pmc-plugins ${WP_PLUGINS_DIR}/pmc-plugins
	elif [[ "${WP_VIP}" =~ classic ]]; then
		mount --bind ${SOURCE_PMC_CORETECH}/pmc-plugins ${WP_CONTENT_DIR}/themes/vip/pmc-plugins
	fi

fi
