stage { 'pre':
  before => Stage['main'],
}

stage { 'final':
  require => Stage['main'],
}

class { 'repository':
  stage => pre,
}

class { 'hdfsRun':
  stage => final,
}

class repository {
  notice('enter repository')

/*  exec { 'apt-get-update':
    command => 'apt-get update',
    path    => ['/bin','/usr/bin'],
  }
*/
}

class { 'mysql::server':
  root_password => 'password',
  service_enabled => true,
  require         => Class['repository']
}
/*
mysql_user { 'hive@localhost':
  ensure        => present,
  password_hash => mysql_password('hive'),
  require       => Class['mysql::server']
}
*/
mysql::db { 'metastore_db':
  ensure    => present,
  user      => 'hive',
  password  => 'hive',
  host      => 'localhost',
  grant     => ['ALL'],
  charset   => 'latin1',
  /*require   => Class['hive@localhost']*/
}

/*mysql_grant { 'hive@localhost/metastore_db.*':
  ensure      => present,
  options     => ['GRANT'],
  user        => 'hive@localhost',
  table       => 'metastore_db.*',
  privileges  => ['ALL'],
  require     => Class['mysql:db']
}
*/

class { 'hadoop' :
  masterNode	=> '10.17.3.10',
  slaveNodes	=> ['10.17.3.10', '10.17.3.11', '10.17.3.12'],
  distrFile		=> "hadoop-1.2.1",
  hadoopHome	=> "/home/vagrant/hadoop",
  javaHome    => '/usr/lib/jvm/jdk1.7.0_51'
}

class { 'hive':
  hiveDistrFile  => 'apache-hive-0.13.1-bin',
  hiveHome       => '/home/vagrant/apache-hive-0.13.1-bin',
  masterNode     => '10.17.3.10'
}

class { 'presto':
  distrServer   => 'presto-server-0.69',
  distrCli      => 'presto-cli-0.69-executable.jar',
  prestoHome    => '/home/vagrant/presto-server-0.69',
  metaserver    => '10.17.3.10',
}

package { 'vim':
  ensure => installed,
}

package { 'tree':
  ensure => installed,
}

package { 'git':
  ensure => installed,
}

exec { 'dot-project':
  cwd     => '/home/vagrant',
  command => 'git clone https://github.com/robinloxley1/dotfiles.git',
  path    => '/usr/bin:/bin:/usr/sbin',
  unless  => 'test -d /home/vagrant/dotfiles',
  require => Package['git'],
}

class hdfsRun {
  notice("hostname is ${hostname}")
  notify {'formatting dfs':
    message => 'formatting dfs now',
  }
 
  if $hostname =~ /^master.*/ {
    Exec['format hdfs'] -> Notify['formatting dfs'] 
    exec { 'format hdfs':
      user      => vagrant,
      command   => '/home/vagrant/hadoop/bin/hadoop namenode -format -force',
      onlyif    => '/usr/bin/test ! -d /app/hadoop/tmp/dfs',
    }

    file { '/tmp/init-hive-dfs.sh':
      source  => "puppet:///modules/hive/init-hive-dfs.sh",
      owner   =>  vagrant,
      mode    =>  755,
      ensure  => present,
    }

    exec { 'run init-hive-dfs.sh':
      cwd       => '/tmp',
      path      => '/usr/bin:/bin:/usr/sbin:/home/vagrant/hadoop/bin',
      command   => "bash -c 'source /home/vagrant5/.bashrc;. init-hive-dfs.sh'",
      user      => vagrant,
      require   => [ Exec['format hdfs'], File['/tmp/init-hive-dfs.sh'] ],
      logoutput => true,
    }
    
/*    exec { 'start-dfs.sh':
      user      => vagrant,
      command   => '/home/vagrant/hadoop/bin/start-dfs.sh',
      require   => Exec['format hdfs'],
    }
    
    exec { 'mkdir dfs /tmp':
      user      => vagrant,
      command   => '/home/vagrant/hadoop/bin/hadoop fs -mkdir /tmp',
      onlyif    => '/home/vagrant/hadoop/bin/hadoop dfs -test -d /tmp 2>&1 | grep -q "does not exist"',
      require   => Exec['start-dfs.sh'],
    }
    
    exec { 'mkdir dfs /user/hive/warehouse':
      user      => vagrant,
      command   => '/home/vagrant/hadoop/bin/hadoop fs -mkdir /user/hive/warehouse',
      unless    => '/home/vagrant/hadoop/bin/hadoop fs -test -d /user/hive/warehouse',
      require   => Exec['start-dfs.sh'],
    }

    exec { 'grant dfs /tmp':
      user      => vagrant,
      command   => '/home/vagrant/hadoop/bin/hadoop fs -chmod g+w /tmp',
      require   => Exec['mkdir dfs /tmp'],
    }
    
    exec { 'grant dfs /user/hive/warehouse':
      user      => vagrant,
      command   => '/home/vagrant/hadoop/bin/hadoop fs -chmod g+w /user/hive/warehouse',
      require   => Exec['mkdir dfs /user/hive/warehouse'],
    }
*/

  }   
}

include java

/*involve class once by include or class running as hdfsRun*/
