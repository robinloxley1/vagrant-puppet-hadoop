vagrant-puppet-hadoop
=====================

deploying 3 nodes virtual hadoop cluster with hive, presto etc on my dev mac.

Download binaries

to modules/java/files/jdk-7u60-linux-x64.gz
to modules/hadoop/files/hadoop-1.2.1.tar.gz
to modules/hive/files/apache-hive-0.13.1-bin.tar.gz
to modules/presto/files/presto-cli-0.69-executable.jar
to modules/presto/files/presto-server-0.69.tar.gz

To run init-db.sql
Download

ml-100k.zip from http://grouplens.org/datasets/movielens/
employees_db.tar.bz2 from employees_db-full-1.0.6.tar.bz2

after install go to master

do: 1. init-hive 2. init-db 3. open hive to test.
