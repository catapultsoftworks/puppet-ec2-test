$home = "/home/ubuntu"
$as_ubuntu = '/usr/bin/sudo -u ubuntu -H bash -l -c'
$ruby_ver = "1.9.3"
$exec_path = "/bin/:/sbin/:/usr/bin/:/usr/sbin/"

class rvm_stuff{
    package{'curl':
    	ensure => installed,
    	provider => $package_manager
    }	
    exec { 'install_rvm':
      command => "${as_ubuntu} 'curl -L https://get.rvm.io | bash -s stable'",
      creates => "${home}/.rvm",
      require => Package['curl'],
      path => "${exec_path}"
    }
    exec { 'source rvm profile':
	command => "${as_ubuntu} 'source ~/.profile'",
	require => Exec['install_rvm']
    }
    exec { 'install_ruby':
      command => "${home}/.rvm/bin/rvm install ${ruby_ver}",
      creates => "${home}/.rvm/bin/ruby",
      require => Exec['install_rvm'],
      path => "${exec_path}:/home/ubuntu/.rvm/bin/rvm"
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
#include nginx
#include unicorn
