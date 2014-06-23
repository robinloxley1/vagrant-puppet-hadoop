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
    command   => 'apt-get update',
    path      => ['/bin','/usr/bin'],
    timeout   => 0,
    logoutput  => true,
  }
*/
}

class { 'mysql::server':
  root_password     => 'password',
  service_enabled   => true,
  override_options  => {'mysqld' => { 'bind_address' => '0.0.0.0' } },
  require           => Class['repository']
}

mysql::db { 'metastore_db':
  ensure    => present,
  user      => 'hive',
  password  => 'hive',
  host      => 'localhost',
  grant     => ['ALL'],
  charset   => 'latin1',
  collate   => 'latin1_bin',
}

mysql_grant { 'root@%/*.*':
  ensure      => present,
  options     => ['GRANT'],
  privileges  => ['ALL'],
  table       => '*.*',
  user        => 'root@%',
}

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

    file { '/home/vagrant/init-hive-dfs.sh':
      source  => "puppet:///modules/hive/init-hive-dfs.sh",
      owner   =>  vagrant,
      mode    =>  755,
      ensure  => present,
    }

    file { '/home/vagrant/init-db.sql':
      source  => "puppet:///modules/hive/init-db.sql",
      owner   =>  vagrant,
      mode    =>  755,
      ensure  => present,  
    }

    file { '/home/vagrant/weekday_mapper.py':
      source  => "puppet:///modules/hive/weekday_mapper.py",
      owner   =>  vagrant,
      mode    =>  755,
      ensure  => present,
    }

/*
    exec { 'run init-hive-dfs.sh':
      cwd       => '/home/vagrant',
      path      => '/usr/bin:/bin:/usr/sbin:/home/vagrant/hadoop/bin',
      command   => "bash -c 'source /home/vagrant5/.bashrc;. init-hive-dfs.sh'",
      user      => vagrant,
      require   => [ Exec['format hdfs'], File['/home/vagrant/init-hive-dfs.sh'] ],
      logoutput => true,
    }
*/
  }   
}

include java

/*involve class once by include or class running as hdfsRun*/
