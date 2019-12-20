#!/bin/sh
echo "Make sure you've cloned the VVV repo and you are in the root of it"
echo "It looks like you're in `pwd`"
echo -e "\nClone VVV or CONTINUE without cloning?"
select yn in "clone" "continue"; do case $yn in
  clone ) git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git && cd VVV && break;;
  continue ) break;;
	esac
done

echo -e "\nCopy the config.yml for VVV into config/config.yml ( this will overwrite if existing ) or continue without copying?"
select yn in "yes" "no"; do case $yn in
  yes ) curl -o config/config.yml https://raw.githubusercontent.com/penske-media-corp/httpatterns/master/vvv/config.yml && break;;
  no ) break;;
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
if [ ! -d "www/phpcs/CodeSniffer/Standards/pmc-codesniffer" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-codesniffer.git www/phpcs/CodeSniffer/Standards/pmc-codesniffer && echo "phpcs usage: phpcs --standard=/srv/www/phpcs/CodeSniffer/pmc-codesniffer/... some.php"; fi

if [ ! -d "www/pmc/coretech/pmc-core" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-core-v2.git www/pmc/coretech/pmc-core; fi
if [ ! -d "www/pmc/coretech/pmc-core-v2" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-core-v2.git www/pmc/coretech/pmc-core-v2; fi
if [ ! -d "www/pmc/coretech/pmc-plugins" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-plugins.git www/pmc/coretech/pmc-plugins; fi

echo -e "\nInstalling go plugins... According to https://wpvip.com/documentation/vip-go/local-vip-go-development-environment/#vvv-for-vip-go-development"
if [ ! -d "www/pmc/vipgo/pmc-vip-go-plugins" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-vip-go-plugins.git www/pmc/vipgo/pmc-vip-go-plugins; fi
if [ ! -d "www/pmc/vipgo/vip-go-mu-plugins-built" ]; then git clone https://github.com/automattic/vip-go-mu-plugins-built.git www/pmc/vipgo/vip-go-mu-plugins-built && git -C www/pmc/vipgo/vip-go-mu-plugins-built submodule update --init --recursive; fi

echo -e "\nInstalling wpcom plugins..."
if [ ! -d "www/pmc/wpcom/wordpress-vip-plugins" ]; then git clone https://bitbucket.org/penskemediacorp/wordpress-vip-plugins.git www/pmc/wpcom/wordpress-vip-plugins; fi
if [ ! -d "www/pmc/wpcom/vip-wpcom-mu-plugins" ]; then git clone https://github.com/automattic/vip-wpcom-mu-plugins.git www/pmc/wpcom/vip-wpcom-mu-plugins && git -C www/pmc/wpcom/vip-wpcom-mu-plugins submodule update --init --recursive; fi

echo -e "\nBuild amp for go?"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant ssh -- -t 'cd /srv/www/pmc/vipgo/pmc-vip-go-plugins/amp && composer install && npm install && npm run build --force' && break;;
  no ) break;;
  esac
done

echo -e "\nBuild amp for wpcom?"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant ssh -- -t 'cd /srv/www/pmc/wpcom/vip-wpcom-mu-plugins/amp-wp && composer install && npm install && npm run build --force' && break;;
  no ) break;;
  esac
done

vagrant ssh -- -t 'if ! grep -q PMC_PHPUNIT_BOOTSTRAP ~/.bashrc; then echo export PMC_PHPUNIT_BOOTSTRAP="/srv/www/pmc/coretech/pmc-plugins/pmc-unit-test/bootstrap.php" >> ~/.bashrc; fi'

echo -e "\nDetecting PMC sites..."
for i in $(ls -d www/pmc-* | xargs -n1 basename)
  do
  if [ ! -d www/$i/public_html/wp-content/themes/$i ]; then git clone https://bitbucket.org/penskemediacorp/$i.git www/$i/public_html/wp-content/themes/$i; fi
  echo -e "\nIs $i go or wpcom?"
  select yn in "go" "wpcom"; do case $yn in
    go ) \
      vagrant ssh -- -t "cd /srv/www/$i/public_html && wp user create pmc pmc@pmc.test --user_pass=pmc --role=administrator"
      CONSTANTS="WP_DEBUG DISALLOW_FILE_MODS DISALLOW_FILE_EDIT AUTOMATIC_UPDATER_DISABLED"
      for constant in $CONSTANTS; do vagrant ssh -- -t "cd /srv/www/$i/public_html && wp config set $constant true --raw"; done
      vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/mu-plugins"
      vagrant ssh -- -t "ln -sf /srv/www/pmc/coretech/pmc-plugins /srv/www/$i/public_html/wp-content/plugins"
      vagrant ssh -- -t "ln -sf /srv/www/pmc/vipgo/pmc-vip-go-plugins/* /srv/www/$i/public_html/wp-content/plugins"
      vagrant ssh -- -t "ln -sf /srv/www/pmc/vipgo/vip-go-mu-plugins-built/* /srv/www/$i/public_html/wp-content/mu-plugins"
      break;;
    wpcom ) \
      vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/mu-plugins /srv/www/$i/public_html/wp-content/themes/vip/plugins"
      vagrant ssh -- -t "ln -sf /srv/www/pmc/coretech/pmc-plugins /srv/www/$i/public_html/wp-content/themes/vip"
      vagrant ssh -- -t "ln -sf /srv/www/pmc/wpcom/vip-wpcom-mu-plugins/* /srv/www/$i/public_html/wp-content/mu-plugins"
      vagrant ssh -- -t "ln -sf /srv/www/pmc/wpcom/wordpress-vip-plugins/* /srv/www/$i/public_html/wp-content/themes/vip/plugins"
      #@TODO: svn checkout stuff
        break;;
    esac
  done
  if grep -q pmc-core www/$i/public_html/wp-content/themes/$i/style.css; then vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/themes/vip && ln -sf /srv/www/pmc/coretech/pmc-core /srv/www/$i/public_html/wp-content/themes/vip"; fi
  if grep -q pmc-core-v2 www/$i/public_html/wp-content/themes/$i/style.css; then vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/themes/vip && ln -sf /srv/www/pmc/coretech/pmc-core-v2 /srv/www/$i/public_html/wp-content/themes/vip"; fi
done;

echo -e "\nYou should now have PMC sites setup in vagrant"
echo -e "\nGo To: vvv.test in your browser to see what you can do"
