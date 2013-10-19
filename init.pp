$home = "/home/ubuntu"
$as_ubuntu = 'sudo -u ubuntu -H bash -l -c'
$ruby_ver = "1.9.3"

class rvm_stuff{
    exec { 'install_rvm':
      command => "${as_ubuntu} 'curl -L https://get.rvm.io | bash -s stable'",
      creates => "${home}/.rvm",
      require => Package['curl'],
      path => "${home}"
    }
    exec { 'install_ruby':
      command => "${as_ubuntu} '${home}/.rvm/bin/rvm install ${ruby_ver} --latest-binary --autolibs=enabled && rvm --fuzzy alias create default ${ruby_ver}'",
      creates => "${home}/.rvm/bin/ruby",
      require => Exec['install_rvm'],
      path => "${home}"
    }
    
    package{'curl':
    	ensure => installed,
    	provider => $package_manager
    }
}
class nginx {
    package {'nginx':
    	ensure => latest,
	provider => $package_manager
    }
}

class unicorn {
    package {'unicorn':
	ensure => latest,
	provider => $package_manager
    }
}

$package_manager = $operatingsystem ?{
	ubuntu	=> apt,
	centos	=> yum
}
include rvm_stuff
include nginx
include unicorn
