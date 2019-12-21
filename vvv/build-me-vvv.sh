#!/bin/sh
echo -e "If you are on windows then you need to install wsl"
echo -e "https://docs.microsoft.com/en-us/windows/wsl/install-win10"
echo -e "Please make sure you're connected to the internet with a good connection this will take a while"
echo -e "\nMake sure you've cloned the VVV repo and you are in the root of it"
echo -e "\nIt looks like you're in `pwd`"
echo -e "\nYour current repo is:"
echo -e "`git remote -v`"
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
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=999999'
if [ ! -d "www/phpcs/CodeSniffer/Standards/pmc-codesniffer" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-codesniffer.git www/phpcs/CodeSniffer/Standards/pmc-codesniffer; fi
#@TODO: Configure phpcs standards
# cd /srv/provision/phpcs
# vagrant ssh -- -t "phpcs --config-set installed_paths ./CodeSniffer/Standards/WordPress/,./CodeSniffer/Standards/VIP-Coding-Standards/,./CodeSniffer/Standards/PHPCompatibility/,./CodeSniffer/Standards/PHPCompatibilityParagonie/,./CodeSniffer/Standards/PHPCompatibilityWP/"

echo -e "\nInstalling coretech..."
if [ ! -d "www/pmc/coretech/pmc-core" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-core.git www/pmc/coretech/pmc-core; fi
if [ ! -d "www/pmc/coretech/pmc-core-2017" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-core-2017.git www/pmc/coretech/pmc-core-2017; fi
if [ ! -d "www/pmc/coretech/pmc-core-v2" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-core-v2.git www/pmc/coretech/pmc-core-v2; fi
if [ ! -d "www/pmc/coretech/pmc-robbreport-2017-v2" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-robbreport-2017-v2.git www/pmc/coretech/pmc-robbreport-2017-v2; fi
if [ ! -d "www/pmc/coretech/pmc-plugins" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-plugins.git www/pmc/coretech/pmc-plugins; fi

echo -e "\nInstalling go plugins... According to https://wpvip.com/documentation/vip-go/local-vip-go-development-environment/#vvv-for-vip-go-development"
if [ ! -d "www/pmc/vipgo/pmc-vip-go-plugins" ]; then git clone https://bitbucket.org/penskemediacorp/pmc-vip-go-plugins.git www/pmc/vipgo/pmc-vip-go-plugins; fi
if [ ! -d "www/pmc/vipgo/vip-go-mu-plugins-built" ]; then git clone https://github.com/automattic/vip-go-mu-plugins-built.git www/pmc/vipgo/vip-go-mu-plugins-built && git -C www/pmc/vipgo/vip-go-mu-plugins-built submodule update --init --recursive; fi

echo -e "\nInstalling wpcom plugins..."
if [ ! -d "www/pmc/wpcom/wordpress-vip-plugins" ]; then git clone https://bitbucket.org/penskemediacorp/wordpress-vip-plugins.git www/pmc/wpcom/wordpress-vip-plugins; fi
if [ ! -d "www/pmc/wpcom/vip-wpcom-mu-plugins" ]; then git clone https://github.com/automattic/vip-wpcom-mu-plugins.git www/pmc/wpcom/vip-wpcom-mu-plugins && git -C www/pmc/wpcom/vip-wpcom-mu-plugins submodule update --init --recursive; fi

echo -e "\nBuild amp for go?"
select yn in "yes" "no"; do case $yn in
  #@NOTE: --force is needed so amp can actually build itself
  yes ) vagrant ssh -- -t 'cd /srv/www/pmc/vipgo/pmc-vip-go-plugins/amp && composer install && npm install && npm run build --force' && break;;
  no ) break;;
  esac
done

echo -e "\nBuild amp for wpcom?"
select yn in "yes" "no"; do case $yn in
  #@NOTE: --force is needed so amp can actually build itself
  yes ) vagrant ssh -- -t 'cd /srv/www/pmc/wpcom/vip-wpcom-mu-plugins/amp-wp && composer install && npm install && npm run build --force' && break;;
  no ) break;;
  esac
done

# @NOTE: Not all of these tools are needed but are useful to have inside of the dev machine feel free to submit a PR if you think any new tools should be added/removed from this list
echo -e "\nInstall dev tools into vagrant?"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant ssh -- -t "sudo npm install -g coolaj86/yaml2json && \
    sudo apt-get update && sudo apt-get install -y \
    awscli \
    git-extras \
    httpie \
    jq \
    neovim \
    ranger \
    tig \
    vifm" && break;;
  no ) break;;
  esac
done

echo -e "\nInstall vagrant-scp plugin? ( you pretty much have to say yes if it's not already installed)"
echo "https://github.com/invernizzi/vagrant-scp"
select yn in "yes" "no"; do case $yn in
  yes ) vagrant plugin install vagrant-scp && break;;
  no ) break;;
  esac
done
#@NOTE: if more than one vagrant default then we may have to specify before : in scp command
vagrant scp config/config.yml :/tmp/config.yml

# echo -e "\nInstall wpcom sites?"
# select yn in "yes" "no"; do case $yn in
#   yes )
# https://github.com/Varying-Vagrant-Vagrants/custom-site-template/blob/aa1680b3cb93b5f38055e56118f697a19128b78b/provision/vvv-init.sh#L61
# install content from s3
#     vagrant ssh -- -t "mkdir -p /srv/www/wpcom/public_html/wp-content/mu-plugins"
#     vagrant ssh -- -t "mkdir -p /srv/www/wpcom/public_html/wp-content/mu-plugins /srv/www/wpcom/public_html/wp-content/themes/vip/plugins"
#     vagrant ssh -- -t "cd /srv/www/wpcom/public_html && wp user create pmcdev pmc@pmc.test --user_pass=pmcdev --role=administrator"
#     vagrant ssh -- -t "ln -svf /srv/www/pmc/coretech/* /srv/www/wpcom/public_html/wp-content/themes/vip"
#     vagrant ssh -- -t "ln -svf /srv/www/pmc/wpcom/vip-wpcom-mu-plugins/* /srv/www/wpcom/public_html/wp-content/mu-plugins"
#     vagrant ssh -- -t "ln -svf /srv/www/pmc/wpcom/wordpress-vip-plugins/* /srv/www/wpcom/public_html/wp-content/themes/vip/plugins"
#     # Pull directly from config
#     wpcom_sites=$(vagrant ssh -- -t "yaml2json /tmp/config.yml | jq -r '.sites.wpcom.hosts[]'")
#     for site in $wpcom_sites
#       do
#         #@DEL?
#         if [[ ! -d "www/wpcom/public_html/wp-content/themes/${site%%.*}" && "wpcom.test" != $site ]]; then git clone "https://bitbucket.org/penskemediacorp/${site%%.*}" "www/wpcom/public_html/wp-content/themes/${site%%.*}"; fi
#           # vagrant ssh -- -t 'cd /srv/www/wpcom/public_html && wp theme activate ${site%%.*} --url=$site'
#     done
#     break;;
#   no ) break;;
#   esac
# done
#
echo -e "\nInstall vipgo sites?"
select yn in "yes" "no"; do case $yn in
  yes )
    echo -e "\nDetecting PMC VIP-GO sites in www/pmc-* ..."
    for i in $(ls -d www/pmc-* | xargs -n1 basename)
      do
      # install primary theme
      if [ ! -d www/$i/public_html/wp-content/themes/$i ]; then git clone https://bitbucket.org/penskemediacorp/$i.git www/$i/public_html/wp-content/themes/$i; fi

      # delete wordpress-importer as it's installed by provisioner and causes fatal on mu-plugins installation
      vagrant ssh -- -t "wp plugin delete wordpress-importer --path=/srv/www/$i/public_html"

      # setup default user 2fa bypass as per: https://wpvip.com/documentation/vip-go/local-vip-go-development-environment/#step-5-creating-an-admin-user-via-wp-cli
      vagrant ssh -- -t "wp user create pmcdev pmc@pmc.test --user_pass=pmcdev --role=administrator --path=/srv/www/$i/public_html"

      # vipgo-plugins symlink
      vagrant ssh -- -t "ln -svf /srv/www/pmc/vipgo/pmc-vip-go-plugins/* /srv/www/$i/public_html/wp-content/plugins"

      # mu-plugins symlink
      vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/mu-plugins"
      vagrant ssh -- -t "ln -svf /srv/www/pmc/vipgo/vip-go-mu-plugins-built/* /srv/www/$i/public_html/wp-content/mu-plugins"

      # coretech symlink
      vagrant ssh -- -t "ln -svf /srv/www/pmc/coretech/pmc-plugins /srv/www/$i/public_html/wp-content/plugins"
      if grep -q pmc-core www/$i/public_html/wp-content/themes/$i/style.css; then vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/themes/vip && ln -sf /srv/www/pmc/coretech/pmc-core /srv/www/$i/public_html/wp-content/themes/vip"; fi
      if grep -q pmc-core-2017 www/$i/public_html/wp-content/themes/$i/style.css; then vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/themes/vip && ln -sf /srv/www/pmc/coretech/pmc-core-2017 /srv/www/$i/public_html/wp-content/themes/vip"; fi
      if grep -q pmc-core-v2 www/$i/public_html/wp-content/themes/$i/style.css; then vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/themes/vip && ln -sf /srv/www/pmc/coretech/pmc-core-v2 /srv/www/$i/public_html/wp-content/themes && ln -sf /srv/www/pmc/coretech/pmc-core-v2 /srv/www/$i/public_html/wp-content/themes/vip"; fi
      if grep -q pmc-robbreport-2017-v2 www/$i/public_html/wp-content/themes/$i/style.css; then vagrant ssh -- -t "mkdir -p /srv/www/$i/public_html/wp-content/themes/vip && ln -sf /srv/www/pmc/coretech/pmc-robbreport-2017-v2 /srv/www/$i/public_html/wp-content/themes/vip"; fi

      # Activate our main theme
      vagrant ssh -- -t "wp theme activate $i --path=/srv/www/$i/public_html"
    done;
    break;;
  no ) break;;
  esac
done

echo -e "\nYou should now have ALL WP PMC sites setup in VVV"
echo -e "\nNavigate To: vvv.test in your browser to see what you can do"
