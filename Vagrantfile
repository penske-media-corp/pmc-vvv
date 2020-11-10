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
require File.join( __dir__,'lib','functions.rb' )

# Auto install all required plugins
install_required_plugins()

FileUtils.mkdir_p("./src/coretech/pmc-plugins") unless Dir.exist?("./src/coretech/pmc-plugins")
FileUtils.mkdir_p("./src/coretech/pmc-core-v2") unless Dir.exist?("./src/coretech/pmc-core-v2")
FileUtils.cp( File.join( 'provision', 'provision-post.sh' ), File.join( 'vvv', 'provision', 'provision-post.sh' ) );

# Copy our config.yml to vvv folder, currently there is no way for us to use a different config file from different location

# development testing for now
FileUtils.cp( 'config-tests.yml', File.join( 'vvv', 'config', 'config.yml' ) );
FileUtils.cp( 'Customfile', File.join( 'vvv', 'Customfile' ) );

ENV['VVV_SKIP_LOGO'] = 'true'
Dir.chdir 'vvv'
exec "vagrant #{ARGV.join(' ')}"
Kernel.exit!(0)
