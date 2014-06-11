#!/bin/bash
start-dfs.sh >/dev/null 2>&1

mode=`hadoop dfsadmin -safemode get`
while [[ "$mode" = *ON* ]]
do
  echo $mode
  sleep 5
  mode=`hadoop dfsadmin -safemode get`
done

var=`hadoop fs -test -d /tmp 2>&1`
echo $var
if [[ "$var" = *does\ not\ exist* ]];
then
  echo "creating /tmp"
  hadoop fs -mkdir /tmp
  hadoop fs -chmod g+x /tmp
fi

var=`hadoop fs -test -d /user/hive/warehouse 2>&1`
echo $var
if [[ "$var" = *does\ not\ exist* ]]
then
  echo "creating /user/hive/warehouse"
  hadoop fs -mkdir /user/hive/warehouse
  hadoop fs -chmod g+x /user/hive/warehouse
fi

#stop-dfs.sh >/dev/null 2>&1