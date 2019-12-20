#!/bin/sh
echo "Make sure you've cloned the VVV repo and you are in the root of it"
echo ".... git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git"
echo "CONTINUE?"
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
echo "CONTINUE?"
select yn in "yes" "no"; do case $yn in
  yes ) break;;
  no ) exit;;
	esac
done

# Clone the repos
git clone https://bitbucket.org/penskemediacorp/pmc-codesniffer.git www/phpcs/CodeSniffer/Standards/pmc-codesniffer
echo "phpcs usage:"
echo "phpcs --standard=/srv/www/phpcs/CodeSniffer/pmc-codesniffer/... some.php"
git clone https://bitbucket.org/penskemediacorp/pmc-core-v2.git www/pmc/pmc-core-v2
git clone https://bitbucket.org/penskemediacorp/pmc-plugins.git www/pmc/pmc-plugins
git clone https://bitbucket.org/penskemediacorp/pmc-vip-go-plugins.git www/pmc/pmc-vip-go-plugins
git clone https://bitbucket.org/penskemediacorp/wordpress-vip-plugins.git www/pmc/wordpress-vip-plugins

# According to https://wpvip.com/documentation/vip-go/local-vip-go-development-environment/#vvv-for-vip-go-development
git clone https://github.com/automattic/vip-go-mu-plugins.git www/pmc/vip-go-mu-plugins
git -C www/pmc/vip-go-mu-plugins pull origin master
git -C www/pmc/vip-go-mu-plugins submodule update --init --recursive

git clone https://github.com/automattic/vip-wpcom-mu-plugins.git www/pmc/vip-wpcom-mu-plugins
git -C www/pmc/vip-wpcom-mu-plugins submodule init
git -C www/pmc/vip-wpcom-mu-plugins submodule update --init --recursive

echo "Start the vagrant machine i.e. vagrant up --provision?"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant up --provision && break;;
  no ) break;;
  esac
done

echo "Build amp for go?"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant ssh -- -t 'cd /srv/www/pmc/pmc-vip-go-plugins/amp && composer install && npm install && npm run build' && break;;
  no ) break;;
  esac
done

echo "Build amp for wpcom?"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant ssh -- -t 'cd /srv/www/pmc/vip-wpcom-mu-plugins/amp-wp && composer install && npm install && npm run build' && break;;
  no ) break;;
  esac
done

vagrant ssh -- -t 'if ! grep PMC_PHPUNIT_BOOTSTRAP ~/.bashrc; then echo export PMC_PHPUNIT_BOOTSTRAP="/srv/www/pmc/public_html/wp-content/alugins/pmc-plugins/pmc-unit-test/bootstrap.php" >> ~/.bashrc; fi'

for i in $(ls -d www/pmc-* | xargs -n1 basename)
  do
  git clone https://bitbucket.org/penskemediacorp/$i.git www/$i/public_html/wp-content/themes/$i
  vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/mu-plugins && ln -sfv /srv/www/pmc/pmc-plugins /srv/www/$i/public_html/wp-content/plugins && ln -sfv /srv/www/pmc/pmc-vip-go-plugins/* /srv/www/$i/public_html/wp-content/plugins"
  echo "Is $i go or wpcom?"
  select yn in "go" "wpcom"; do case $yn in
    go ) vagrant ssh -- -t "ln -sfv /srv/www/pmc/vip-go-mu-plugins/* /srv/www/$i/public_html/wp-content/mu-plugins" && break;;
    wpcom ) vagrant ssh -- -t "ln -sfv /srv/www/pmc/vip-wpcom-mu-plugins/* /srv/www/$i/public_html/wp-content/mu-plugins" && break;;
    esac
  done
  echo "Does $i use pmc-core-v2?"
  select yn in "yes" "no"; do case $yn in
    yes ) vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/themes/vip && ln -sfv /srv/www/pmc/pmc-core-v2 /srv/www/$i/public_html/wp-content/themes/vip" && break;;
    no ) break;;
    esac
  done
done;

echo "You should now have PMC sites setup in vagrant"
echo "Go To: vvv.test in your browser to see what you can do"
