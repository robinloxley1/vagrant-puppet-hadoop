class hadoop ( $masterNode, $slaveNodes, $distrFile, $hadoopHome, $javaHome) {
  Exec {
    path => [ "/usr/bin", "/bin", "/usr/sbin" ]
  }

  file { "/tmp/${distrFile}.tar.gz" :
    source  => "puppet:///modules/hadoop/${distrFile}.tar.gz",
    owner   => vagrant,
    mode    => 755,
    ensure  => present,
  }

  exec { 'extract distr' :
    cwd     => '/tmp',
    command => "tar xf ${distrFile}.tar.gz",
    creates => "${hadoopHome}",
    user    => vagrant,
    require => File["/tmp/${distrFile}.tar.gz"]
  }

  exec { 'move distr' :
    cwd     => "/tmp",
    command => "mv ${distrFile} ${hadoopHome}",
    creates => "${hadoopHome}",
    user    => vagrant,
    require => Exec['extract distr']
  }
  
/*  file { "/etc/profile.d/hadoop.sh":
    content => "export HADOOP_PREFIX=\"${hadoopHome}\"
    export PATH=\"\$PATH:\$HADOOP_PREFIX/bin\""
  } */

  file { "/etc/profile.d/hadoop.sh":
    content => "export HADOOP_PREFIX=${hadoopHome}
export PATH=\$PATH:\$HADOOP_PREFIX/bin"
  }

  file { "${hadoopHome}/conf/slaves" :
    content => template( 'hadoop/slaves.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => Exec['move distr']
  }

  file { "${hadoopHome}/conf/masters" :
    content => template( 'hadoop/masters.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => Exec['move distr'] 
  }
  
  file { "${hadoopHome}/conf/hadoop-env.sh" :
    content => template( 'hadoop/hadoop-env.sh.erb'),
    mode    => '0644',
    owner   => vagrant,
    group   => vagrant,
    require => Exec['move distr'] 
  }
  
  file { "${hadoopHome}/conf/core-site.xml" :
    content => template( 'hadoop/core-site.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => Exec['move distr'] 
  }
  
  file { "${hadoopHome}/conf/hdfs-site.xml" :
    content => template( 'hadoop/hdfs-site.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => Exec['move distr'] 
  }
  
  file { "${hadoopHome}/conf/mapred-site.xml" :
    content => template( 'hadoop/mapred-site.erb'),
    mode    => 644,
    owner   => vagrant,
    group   => vagrant,
    require => Exec['move distr'] 
  }

  file { ['/app', '/app/hadoop', '/app/hadoop/tmp'] :
    ensure  => directory,
    mode    => '0750',
    owner   => vagrant,
    group   => vagrant,
    require => Exec['move distr']
  }

  file { '/home/vagrant/.ssh/id_rsa' :
    source  => "puppet:///modules/hadoop/id_rsa",
    mode    => 600,
    owner   => vagrant,
    group   => vagrant
  }

  file { '/home/vagrant/.ssh/id_rsa.pub' :
    source  => "puppet:///modules/hadoop/id_rsa.pub",
    mode    => 600,
    owner   => vagrant,
    group   => vagrant
  }

  ssh_authorized_key { "ssh_key" :
    ensure  => present,
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDhwyZv4zqXYBmfF2iwzfB4Nvpx7YT/M47asVXuJ+sKvOG8Z6cLtLgSedRUSYTLj0Ux8W1oc7TQOKg9viGCjhC14Kxx6+0k+mfPHBWurmS/ty/IQd+q68ggCL21VvBOIEmhdS3zthNHfS0y1UtV3xidafnz/OODQnYDo4NUmYZTY+wKI+ctfBK+PY8WLlYd07tbb3dbTXxnVITvDsxrszd2eZNjUBGCq5KNQLIaaKvttPJ/4LNY5opnhybcnVdI5UFmHcIFtN//bKq4y1hHmZoZo3GLZ14vTRNUgWH9Hi8nOaEZl0jli8FHxVnuuu5Mhppzh0Z63hPxB6uOm9P2ISE/',
    type    => 'ssh-rsa',
    user    => vagrant,
    require => File['/home/vagrant/.ssh/id_rsa.pub']
  }

  host { 'master.gp.net' :
    ensure  => present,
    target  => '/etc/hosts',
    ip      => '10.17.3.10',
  }

  host { 'slave1.gp.net' :
    ensure  => present,
    target  => '/etc/hosts',
    ip      => '10.17.3.11',
  }

  host { 'slave2.gp.net' :
    ensure  => present,
    target  => '/etc/hosts',
    ip      => '10.17.3.12',
  }
}