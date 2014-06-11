class hive ( $hiveDistrFile, $hiveHome, $masterNode) {
  Exec {
    path  => ['/usr/bin', '/bin', '/usr/sbin']
  }

  file { "/tmp/${hiveDistrFile}.tar.gz":
    source  => "puppet:///modules/hive/${hiveDistrFile}.tar.gz",
    owner   =>  vagrant,
    mode    =>  755,
    ensure  =>  present,
  }

  exec { 'extract hiveDistr':
    cwd     => '/tmp',
    command => "tar zxvf ${hiveDistrFile}.tar.gz",
    creates => "${hiveHome}",
    user    => vagrant,
    require =>  File["/tmp/${hiveDistrFile}.tar.gz"],
  }

  exec {  'move hiveDistr':
    cwd     => '/tmp',
    command =>  "mv ${hiveDistrFile} ${hiveHome}",
    creates => "${hiveHome}",
    user    => vagrant,
    require => Exec['extract hiveDistr'],
  }

  file { '/etc/profile.d/hive.sh':
    content => "export HIVE_HOME=${hiveHome}
export PATH=\$PATH:\$HIVE_HOME/bin"
  }

  package { 'mysql connector':
    name    => 'libmysql-java',
    ensure  => installed,
  }

  exec { 'link mysql connector': 
    cwd     => "${hiveHome}/lib",
    command => 'ln -sf /usr/share/java/mysql-connector-java.jar',
    user    => vagrant,
    require => [ Package['mysql connector'], Exec['move hiveDistr'] ],
  }

  file { "${hiveHome}/conf/hive-site.xml":
    content => template('hive/hive-site.xml.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => Exec['move hiveDistr'],
  }

}