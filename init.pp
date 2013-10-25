$home = "/home/ubuntu"
$as_ubuntu = '/usr/bin/sudo -u ubuntu -H bash -l -c'
$ruby_ver = "1.9.3"
$exec_path = "/bin/:/sbin/:/usr/bin/:/usr/sbin/"

#not sure if i can lose the other curl definition
    package{'curl':
    	ensure => installed,
    	provider => $package_manager
    }	
class nodejs{
	package{'nodejs':
		ensure=> installed
	}
}
class neo4j {
    exec { 'get_neo4j_installer':
      command => "${as_ubuntu} 'wget https://raw.github.com/neo4j-contrib/neo4j-puppet/master/go --output-document=\'${home}/neo4j_go\''",
      require => Package['curl'],
      path => "${exec_path}"
    }
}
class version_control{
    package {'git':
    	provider =>	$package_manager
    }
    package {'subversion':
    	provider =>	$package_manager
    }
}
class ruby-dev{
    package {'ruby1.9.1-dev':
    	provider =>	$package_manager
    }
    ->
    package {'gem':
    	ensure =>	latest,
    	provider =>	$package_manager
    }
}
class rvm_stuff{
#    package{'curl':
#    	ensure => installed,
#    	provider => $package_manager
#    }	
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
    
    exec { 'default ruby':
        command => "${home}/.rvm/bin/rvm --default use ${ruby_ver}",
	require => Exec['install_ruby']
    }
    package {'rails':
	ensure => "3.2.14",
	provider => "gem",
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
include version_control
include ruby-dev
include rvm_stuff
include neo4j
include nginx
include unicorn
include nodejs
