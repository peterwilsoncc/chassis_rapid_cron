# Rapid Cron is a replacement for WordPress' built-in cron that runs as a daemon on your system
class rapid_cron (
	$config
) {
	# Set up variables for our templates.
	$path = '/vagrant/content/plugins/rapid-cron'
	$wproot = $config[mapped_paths][wp]

	$version = $config[php]

	if $version =~ /^(\d+)\.(\d+)$/ {
		$package_version = "${version}.*"
		$short_ver = $version
	}
	else {
		$package_version = "${version}*"
		$short_ver = regsubst($version, '^(\d+\.\d+)\.\d+$', '\1')
	}

	if versioncmp($version, '5.4') <= 0 {
		$php_package = 'php5'
		$php_dir = 'php5'
	}
	else {
		$php_package = "php${short_ver}"
		$php_dir = "php/${short_ver}"
	}

	if ( ! empty( $::config[disabled_extensions] ) and 'peterwilsoncc/chassis_rapid_cron' in $config[disabled_extensions] ) {
		$file = absent
		$link = absent
		$present = absent
	} else {
		$file = file
		$link = link
		$present = present
	}

	if versioncmp($facts['os']['distro']['release']['full'], '15.04') >= 0 {
		exec { 'systemctl enable rapid-cron':
			command     => '/bin/systemctl enable rapid-cron',
			refreshonly => true
		}
		file { '/lib/systemd/system/rapid-cron.service':
			ensure  => $file,
			content => template('rapid-cron/systemd.service.erb'),
			notify  => [
				Exec['systemctl-daemon-reload'],
				Exec['systemctl enable rapid-cron'],
			],
		}
		File['/lib/systemd/system/rapid-cron.service'] -> Service['rapid-cron']
	} else {
		file { '/etc/init/rapid-cron.conf':
			ensure  => $file,
			content => template('rapid-cron/upstart.conf.erb'),
		}
		File['/etc/init/rapid-cron.conf'] -> Service['rapid-cron']
	}

	file { "/etc/${php_dir}/mods-available/rapid-cron.ini":
		ensure  => $present,
		content => template('rapid-cron/rapid-cron.ini.erb'),
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		require => Package["${php_package}-fpm"],
		notify  => Service["${php_package}-fpm"],
	}

	file { "/etc/${php_dir}/cli/conf.d/rapid-cron.ini":
		ensure  => $link,
		target  => "/etc/${php_dir}/mods-available/rapid-cron.ini",
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		require => File["/etc/${php_dir}/mods-available/rapid-cron.ini"],
	}

	file { "/etc/${php_dir}/fpm/conf.d/rapid-cron.ini":
		ensure  => $link,
		target  => "/etc/${php_dir}/mods-available/rapid-cron.ini",
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		require => File["/etc/${php_dir}/mods-available/rapid-cron.ini"],
	}

	file { '/etc/rsyslog.d/rapid-cron.conf':
		ensure  => $present,
		content => template('rapid-cron/rapid-cron.conf.erb'),
		owner   => 'root',
		group   => 'root',
		mode    => '0644'
	}

	if ( ! empty( $::config[disabled_extensions] ) and 'chassis/rapid-cron' in $config[disabled_extensions] ) {
		service { 'rapid-cron':
			ensure    => stopped,
			enable    => false,
			restart   => false,
			hasstatus => false
		}
	} else {
		service { 'rapid-cron':
			ensure     => running,
			enable     => true,
			hasrestart => true,
			hasstatus  => true
		}
	}
}
