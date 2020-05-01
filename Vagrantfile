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

# Copy our config.yml to vvv folder, currently there is no way for us to use a different config file from different location

# development testing for now
FileUtils.cp( 'config-tests.yml', File.join( 'vvv', 'config', 'config.yml' ) );
FileUtils.cp( 'Customfile', File.join( 'vvv', 'Customfile' ) );

Dir.chdir 'vvv'
exec "vagrant #{ARGV.join(' ')}"
Kernel.exit!(0)
