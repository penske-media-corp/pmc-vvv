$logger = Vagrant::UI::Colored.new

def install_required_plugins()

	# vagrant-persistent-storage
	# vagrant-git
	# vagrant-docker-compose

	required_plugins = %w( rb-readline vagrant-ghost vagrant-vbguest vagrant-hostsupdater vagrant-disksize )
	missing_plugins = []
	required_plugins.each do |plugin|
		missing_plugins.push(plugin) unless Vagrant.has_plugin? plugin
	end
	if ! missing_plugins.empty?
		install_these = missing_plugins.join(' ')
		$logger.warn "Required following plugins: #{install_these}."
		if system "vagrant plugin install #{install_these}"
			exec "vagrant #{ARGV.join(' ')}"
			Kernel.exit!(0)
		else
			$logger.warn "Error install plugins, please install these plugins then restart vagrant:"
			$logger.warn "   #{install_these}"
			Kernel.exit!(0)
		end
	end

end

# @see https://github.com/psudug/nittany-vagrant/blob/master/Vagrantfile
def detect_max_cpus( default = 1, multiplier = 1 )
	host_os = RbConfig::CONFIG['host_os']
	cpus = 0

	# Give VM 1/4 system memory & access to all cpu cores on the host
	if host_os =~ /darwin/
		cpus = `sysctl -n hw.ncpu`.to_i
	elsif host_os =~ /linux/
		cpus = `nproc`.to_i
	elsif host_os =~ /mingw32/
		cpus = `wmic cpu get NumberOfLogicalProcessors | grep '^[0-9]'`.to_i
	end

	if cpus <= 0
		return default
	end

	return (cpus * multiplier).round
end

# @see https://github.com/psudug/nittany-vagrant/blob/master/Vagrantfile
def detect_max_mem( default = 1024, multiplier = 1 )
	host_os = RbConfig::CONFIG['host_os']
	mem = 0

	# Give VM 1/4 system memory & access to all cpu cores on the host
	if host_os =~ /darwin/
		# sysctl returns Bytes and we need to convert to MB
		mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024
	elsif host_os =~ /linux/
		# meminfo shows KB and we need to convert to MB
		mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024
	elsif host_os =~ /mingw32/
		mem = `wmic os get TotalVisibleMemorySize | grep '^[0-9]'`.to_i / 1024
		if mem < 1024
			mem = 1024
		end
	end

	if mem <= 0
		return default
	end

	return (mem * multiplier).round
end
