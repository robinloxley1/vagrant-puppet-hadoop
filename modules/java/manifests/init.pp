class java(
  $java_archive = 'jdk-7u51-linux-x64.gz',
  $java_home = '/usr/lib/jvm/jdk1.7.0_51',
  $java_folder = 'jdk1.7.0_51')
  {
    Exec {
      path => ['/usr/bin', '/bin', '/usr/sbin']
    }

    file { 'jdk':
      ensure => present,
      path   => "/tmp/${java_archive}",
      source => "puppet:///modules/java/${java_archive}",
      owner  => vagrant,
      mode   => '0755',
    }

    exec { 'extract jdk' :
      cwd     => '/tmp',
      command => "tar zxfv ${java_archive}",
      creates => $java_home,
      require => File['jdk'],
    }

    file { '/usr/lib/jvm' :
      ensure  => directory,
      owner   => vagrant,
      require => Exec['extract jdk'],
    }

    exec { 'move jdk' :
      cwd     => '/tmp',
      creates => $java_home,
      require => File['/usr/lib/jvm'],
      command => "mv ${java_folder} /usr/lib/jvm/",
    }
    
    exec { 'install java' :
      require   => Exec['move jdk'],
      logoutput => true,
      command   => "update-alternatives --install /bin/java java ${java_home}/bin/java 1",
    }
  
    exec { 'set java' :
      require   => Exec['install java'],
      logoutput => true,
      command   => "update-alternatives --set java ${java_home}/bin/java",
    }

    exec { 'install javac' :
      require   => Exec['move jdk'],
      logoutput => true,
      command   => "update-alternatives --install /bin/javac javac ${java_home}/bin/javac 1",
    }

    exec { 'set javac' :
      require   => Exec['install javac'],
      logoutput => true,
      command   => "update-alternatives --set javac ${java_home}/bin/javac",
    }
    
    file { '/etc/profile.d/java.sh' :
      content => "export JAVA_HOME=${java_home}
export PATH=\$PATH:\$JAVA_HOME/bin",
    }
  } 