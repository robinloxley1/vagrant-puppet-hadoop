class presto ($distrServer, $distrCli, $prestoHome, $metaserver) {
  Exec {
    path  => ['/usr/bin','/bin','/usr/sbin']
  }

  file { "/tmp/${distrServer}.tar.gz":
    source  => "puppet:///modules/presto/${distrServer}.tar.gz",
    owner   => vagrant,
    mode    => 755,
    ensure  => present,
  }

  exec { 'extract presto server':
    cwd     => '/tmp',
    command => "tar zxvf ${distrServer}.tar.gz",
    creates => "${prestoHome}",
    user    => vagrant,
    require => File["/tmp/${distrServer}.tar.gz"],
  }
  
  exec { 'move presto server':
    cwd     => '/tmp',
    command => "mv ${distrServer} ${prestoHome}",
    creates => "${prestoHome}",
    user    => vagrant,
    require => Exec['extract presto server'],
  }

  file {"/home/vagrant/${distrCli}":
    source  => "puppet:///modules/presto/${distrCli}",
    owner   => vagrant,
    mode    => 755,
    ensure  => present,
  }

  file { '/home/vagrant/presto':
    ensure  => link,
    target  => "${distrCli}",
    mode    => 'a+x',
    owner   => vagrant,  
    require => File["/home/vagrant/${distrCli}"],
  }

  file { ['/var/presto','/var/presto/data'] :
    ensure  => directory,
    owner   => vagrant,
    mode    => 755,
  }  

  file { "${prestoHome}/etc":
    ensure  => directory,
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => Exec['move presto server'],
  }

  file { "${prestoHome}/etc/node.properties":
    content => template('presto/node.properties.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => File["${prestoHome}/etc"],
  }

  file { "${prestoHome}/etc/jvm.config":
    content => template('presto/jvm.config.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => File["${prestoHome}/etc"],
  }

  file { "${prestoHome}/etc/config.properties":
    content => template('presto/config.properties.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => File["${prestoHome}/etc"],
  }

  file { "${prestoHome}/etc/log.properties":
    content => template('presto/log.properties.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => File["${prestoHome}/etc"],
  }

  file { "${prestoHome}/etc/catalog":
    ensure  => directory,
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => File["${prestoHome}/etc"],
  }

  file { "${prestoHome}/etc/catalog/jmx.properties":
    content => template('presto/jmx.properties.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => File["${prestoHome}/etc/catalog"],
  }

  file { "${prestoHome}/etc/catalog/hive.properties":
    content => template('presto/hive.properties.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => File["${prestoHome}/etc/catalog"],
  }

}  