#!/bin/bash

mkdir -p /home/ih616h/backup
cd /home/ih616h/backup
JAVA='/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java'
TAG='DEVL.cassandra.clusters.password='
PSWD=`grep ^$TAG etc/authBatch.props`
PWD=`$JAVA -cp etc:authz-batch-2.0.18-jar-with-dependencies.jar com.att.cadi.CmdLine regurgitate ${PSWD#*=} etc/keyfile`



# BEGIN Store prev
if [ -e "6day" ]; then
   rm -Rf 6day
fi

PREV=6day
for D in 5day 4day 3day 2day yesterday; do
   if [ -e "$D" ]; then
      mv "$D" "$PREV"
   fi
   PREV="$D"
done

mkdir yesterday
mv *.dat yesterday
gzip yesterday/*

# END Store prev


if [ "$*" = "" ]; then
  DATA="ns role perm ns_attrib user_role cred cert x509 delegate approval approved future notify artifact health history"
else
  DATA=$*
fi
date

CQLSH="/usr/bin/cqlsh `uname -n`.vci.att.com 9042 -u m01891@aaf.localized -k authz -p $PWD"
for T in $DATA ; do
	echo "Creating $T.dat"
	$CQLSH -e  "COPY authz.$T TO '$T.dat' WITH DELIMITER='|'"
done
date
