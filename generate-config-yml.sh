#!/bin/sh

config_yml_file="config.yml"
config_json_file="config.json"

#
# WP-Config Constants
#

global_constants=$(cat <<EOF
        AUTOMATIC_UPDATER_DISABLED: true
        DISALLOW_FILE_EDIT: true
        DISALLOW_FILE_MODS: true
        WP_DEBUG: false
        WP_DEBUG_LOG: true
        WP_DISABLE_FATAL_ERROR_HANDLER: true
EOF
)

classic_constants=$(cat <<EOF
        PMC_IS_VIP_GO_SITE: false
        VIP_GO_APP_ENVIRONMENT: false
        VIP_GO_ENV: false
EOF
)

go_constants=$(cat <<EOF
        PMC_IS_VIP_GO_SITE: true
        VIP_GO_APP_ENVIRONMENT: true
        VIP_GO_ENV: true
EOF
)

#
# VIP Classic
#

classic_sites=$( jq -c '.classic[]' < $config_json_file )

cat << EOF > $config_yml_file
---
#
# THIS IS A GENERATED FILE - DO NOT MODIFY!
#  Generator script: ./$0
#  Generator config: ./$config_json_file
#
sites:

  #
  # VIP Classic
  #

  wpcom:
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template.git
    hosts:
      - wpcom.test
EOF

for classic_site in ${classic_sites}; do
  cat << EOF >> $config_yml_file
      - $( echo "$classic_site" | jq -r '.[1]' ).wpcom.test
EOF
done

cat << EOF >> $config_yml_file
    custom:
      wp_type: subdomain
      wpconfig_constants:
${global_constants}
${classic_constants}

EOF

#
# VIP Go
#

cat << EOF >> $config_yml_file
  #
  # VIP Go
  #

EOF

go_sites=$( jq -c '.go[]' < $config_json_file )

for go_site in ${go_sites}; do
  live_url=$( echo "$go_site" | jq -r '.[0]' )
  theme_slug=$( echo "$go_site" | jq -r '.[1]' )
  cat << EOF >> $config_yml_file
  ${theme_slug}:
    description: "${theme_slug}"
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template.git
    custom:
      delete_default_plugins: true
      install_test_content: true
      wpconfig_constants:
${global_constants}
${go_constants}
      admin_user: admin
      admin_password: password
      admin_email: admin@pmc.test
      live_url: https://${live_url}
    hosts:
      - ${theme_slug}.test

EOF
done

#
# General VVV Config
#

cat << EOF >> $config_yml_file
utilities:
  core:
    - memcached-admin
    - mongodb
    - opcache-status
    - php74
    - phpmyadmin
    - tideways
    - tls-ca
    - webgrind

vm_config:
  cores: 2
  memory: 2048

general:
  db_backup: true
  db_restore: true
  db_share_type: false

vagrant-plugins:
  disksize: 10GB
EOF
