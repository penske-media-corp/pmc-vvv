# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby ts=2 sw=2 et:
Vagrant.require_version '>= 2.2.4'

# Define constant for vvv folder
VVV='vvv'

require "getoptlong"
require 'fileutils'
require 'open3'
require "readline"
require 'yaml'
require './lib/functions.rb'

# Auto install all required plugins
install_required_plugins()

# Copy our config.yml to vvv folder, currently there is no way for us to use a different config file from different location
FileUtils.cp( 'config.yml', File.join( 'vvv', 'config', 'config.yml' ) );

# Load the VVV Vagrantfile
load File.join( VVV, 'Vagrantfile' )

Vagrant.configure('2') do |config|

	config.vm.provision "file", source: "./src/.", destination: "/tmp/pmc-src/"
	config.vm.provision "pmc-src", type: 'shell' do |s|
      s.inline = "rsync -r /tmp/pmc-src/ / && rm -rf /tmp/pmc-src"
      s.privileged = true
    end

	# @TODO submit a PR to VVV project to fix some of these issues
	# Will require an upstream fix to properly support Vagrantfile load from another folder
	# Workaround fix, some of the file folder mapping as Vagranfile load under a sub folder does not reflect vagrant_dir reference :(

	config.vm.synced_folder '../../wp-themes', '/srv/www/wpcom/public_html/wp-content/themes/vip'

	config.vm.synced_folder 'vvv/database/sql/', '/srv/database'
	config.vm.synced_folder 'vvv/config/', '/srv/config'
	config.vm.synced_folder 'vvv/provision/', '/srv/provision'
	config.vm.synced_folder 'vvv/certificates/', '/srv/certificates', create: true

	if File.exist?(File.join(VVV, 'provision', 'provision-custom.sh'))
		config.vm.provision 'default', type: 'shell' do |p|
			p.path = File.join(VVV, 'provision', 'provision-custom.sh')
		end
	else
		config.vm.provision 'default', type: 'shell' do |p|
			p.path = File.join(VVV, 'provision', 'provision.sh')
		end
	end
	config.vm.provision 'dashboard', type: 'shell' do |p|
		p.path = File.join(VVV, 'provision', 'provision-dashboard.sh')
	end

	$vvv_config['utility-sources'].each do |name, args|
		config.vm.provision "utility-source-#{name}", type: 'shell' do |p|
			p.path = File.join(VVV, 'provision', 'provision-utility-source.sh')
		end
	end

	$vvv_config['utilities'].each do |name, utilities|
		utilities = {} unless utilities.is_a? Array
		utilities.each do |utility|
			config.vm.provision "utility-#{name}-#{utility}", type: 'shell' do |p|
				p.path = File.join(VVV, 'provision', 'provision-utility.sh')
			end
		end
	end

	$vvv_config['sites'].each do |site, args|
		next if args['skip_provisioning']

		config.vm.provision "site-#{site}", type: 'shell' do |p|
			p.path = File.join(VVV, 'provision', 'provision-site.sh')
		end
	end

end
