$logger = Vagrant::UI::Colored.new

def install_required_plugins()

	required_plugins = %w( rb-readline vagrant-ghost vagrant-vbguest vagrant-persistent-storage vagrant-git vagrant-docker-compose vagrant-hostsupdater vagrant-disksize )
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
