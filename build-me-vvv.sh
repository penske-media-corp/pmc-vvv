#!/bin/sh
echo "Make sure you've cloned the VVV repo and you are in the root of it"
echo ".... git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git"
echo "it looks like you're in `pwd`"

echo -e "\nCONTINUE?"
select yn in "yes" "no"; do case $yn in
  yes ) break;;
  no ) exit;;
	esac
done
echo "Copy config/default-config.yml -> config/config.yml"
echo ".... cp config/default-config.yml config/config.yml"
echo "Add in the sites you need according to the docs here:"
echo "https://varyingvagrantvagrants.org/docs/en-US/adding-a-new-site/"
echo "At the bare minimum you should add this config per site"
echo "==================="
echo "pmc-your-site:"
echo "  skip_provisioning: false"
echo "  description: 'pmc-your-site'"
echo "  repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template.git"
echo "  hosts:"
echo "    - pmc-your-site.test"
echo "==================="
echo "Then come back to this script and we'll download the plugins and themes we need for each entry that you added to the config"

echo -e "\nCONTINUE?"
select yn in "yes" "no"; do case $yn in
  yes ) break;;
  no ) exit;;
	esac
done

echo -e "\nProvision vagrant machine i.e. vagrant up --provision?"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant up --provision && break;;
  no ) break;;
  esac
done

# Clone the repos
echo -e "\nInstalling pmc core tech..."
git clone https://bitbucket.org/penskemediacorp/pmc-codesniffer.git www/phpcs/CodeSniffer/Standards/pmc-codesniffer
echo "phpcs usage:"
echo "phpcs --standard=/srv/www/phpcs/CodeSniffer/pmc-codesniffer/... some.php"
git clone https://bitbucket.org/penskemediacorp/pmc-core-v2.git www/pmc/coretech/pmc-core-v2
git clone https://bitbucket.org/penskemediacorp/pmc-plugins.git www/pmc/coretech/pmc-plugins

echo -e "\nInstalling go plugins... According to https://wpvip.com/documentation/vip-go/local-vip-go-development-environment/#vvv-for-vip-go-development"
git clone https://bitbucket.org/penskemediacorp/pmc-vip-go-plugins.git www/pmc/vipgo/pmc-vip-go-plugins
git clone https://github.com/automattic/vip-go-mu-plugins-built.git www/pmc/vipgo/vip-go-mu-plugins-built
git -C www/pmc/vipgo/vip-go-mu-plugins-built pull origin master
git -C www/pmc/vipgo/vip-go-mu-plugins-built submodule update --init --recursive

echo -e "\nInstalling wpcom plugins..."
git clone https://bitbucket.org/penskemediacorp/wordpress-vip-plugins.git www/pmc/wpcom/wordpress-vip-plugins
git clone https://github.com/automattic/vip-wpcom-mu-plugins.git www/pmc/wpcom/vip-wpcom-mu-plugins
git -C www/pmc/wpcom/vip-wpcom-mu-plugins submodule update --init --recursive

echo -e "\nBuild amp for go?"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant ssh -- -t 'cd /srv/www/pmc/vipgo/pmc-vip-go-plugins/amp && composer install && npm install && npm run build' && break;;
  no ) break;;
  esac
done

echo -e "\nBuild amp for wpcom?"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant ssh -- -t 'cd /srv/www/pmc/wpcom/vip-wpcom-mu-plugins/amp-wp && composer install && npm install && npm run build' && break;;
  no ) break;;
  esac
done

vagrant ssh -- -t 'if ! grep PMC_PHPUNIT_BOOTSTRAP ~/.bashrc; then echo export PMC_PHPUNIT_BOOTSTRAP="/srv/www/pmc/coretech/pmc-plugins/pmc-unit-test/bootstrap.php" >> ~/.bashrc; fi'
vagrant ssh -- -t "mkdir -p /srv/www/pmc/vipgo/plugins /srv/www/pmc/vipgo/mu-plugins /srv/www/pmc/wpcom/plugins /srv/www/pmc/wpcom/mu-plugins"
vagrant ssh -- -t "ln -sfv /srv/www/pmc/coretech/pmc-plugins /srv/www/pmc/vipgo/plugins"
vagrant ssh -- -t "ln -sfv /srv/www/pmc/coretech/pmc-plugins /srv/www/pmc/wpcom/plugins"
vagrant ssh -- -t "ln -sfv /srv/www/pmc/vipgo/pmc-vip-go-plugins/* /srv/www/pmc/vipgo/plugins"
vagrant ssh -- -t "ln -sfv /srv/www/pmc/vipgo/vip-go-mu-plugins-built/* /srv/www/pmc/vipgo/mu-plugins"
vagrant ssh -- -t "ln -sfv /srv/www/pmc/wpcom/vip-wpcom-mu-plugins/* /srv/www/pmc/wpcom/mu-plugins"
vagrant ssh -- -t "ln -sfv /srv/www/pmc/wpcom/wordpress-vip-plugins/* /srv/www/pmc/wpcom/plugins"

echo -e "\nDetecting PMC sites..."
for i in $(ls -d www/pmc-* | xargs -n1 basename)
  do
  git clone https://bitbucket.org/penskemediacorp/$i.git www/$i/public_html/wp-content/themes/$i
  vagrant ssh -- -t "cd /srv/www/$i/public_html && wp user create pmc pmc@pmc.test --user_pass=pmc --role=administrator"
  CONSTANTS="WP_DEBUG DISALLOW_FILE_MODS DISALLOW_FILE_EDIT AUTOMATIC_UPDATER_DISABLED"
  for constant in $CONSTANTS; do vagrant ssh -- -t "cd /srv/www/$i/public_html && wp config set $constant true --raw"; done
  echo -e "\nIs $i go or wpcom?"
  select yn in "go" "wpcom"; do case $yn in
    go ) \
      vagrant ssh -- -t "cd /srv/www/$i/public_html && wp config set WPMU_PLUGIN_DIR /srv/www/pmc/vipgo/mu-plugins" && \
      vagrant ssh -- -t "cd /srv/www/$i/public_html && wp config set WP_PLUGIN_DIR /srv/www/pmc/vipgo/plugins" && \
      break;;
    wpcom ) \
        vagrant ssh -- -t "cd /srv/www/$i/public_html && wp config set WPMU_PLUGIN_DIR /srv/www/pmc/wpcom/mu-plugins" && \
        vagrant ssh -- -t "cd /srv/www/$i/public_html && wp config set WP_PLUGIN_DIR /srv/www/pmc/wpcom/plugins" && \
        break;;
    esac
  done
  echo -e "\nDoes $i use pmc-core-v2?"
  select yn in "yes" "no"; do case $yn in
    yes ) vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/themes/vip && ln -sfv /srv/www/pmc/coretech/pmc-core-v2 /srv/www/$i/public_html/wp-content/themes/vip" && break;;
    no ) break;;
    esac
  done
done;

echo -e "\nYou should now have PMC sites setup in vagrant"
echo -e "\nGo To: vvv.test in your browser to see what you can do"
