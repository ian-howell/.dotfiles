echo -n "Password:"
read  -s PWD
echo
echo `date`
ENV=`grep CASS_ENV etc/authBatch.props`
ENV=${ENV#*=}


# CQLSH="/usr/bin/cqlsh `uname -n`.vci.att.com 9042 -k authz -u m01891@aaf.localized -p $PWD"
CQLSH="/usr/bin/cqlsh -k authz"


if [ "$*" = "" ]; then
	DATA=""
	for Tdat in `ls *.dat`; do
    	   if [ -s "${Tdat}" ]; then
		DATA="$DATA ${Tdat%.dat}"
	   fi
	done
else
	DATA="$*"
fi

echo "You are about to REPLACE the data in the $ENV DB for the following tables:"
echo "$DATA"
echo -n 'If you are VERY sure, type "YES": '
read YES

if [ ! "$YES" = "YES" ]; then
	echo 'Exiting ...'
	exit
fi

UPLOAD=""
for T in $DATA; do
    if [ -s "${T}.dat" ]; then
	echo $T
	case "$T" in
	   # 2.1.14 still has NULL problems for COPY.  Fixed in 2.1.15+
	   "approval"|"artifact"|"cred"|"ns"|"x509")
		$CQLSH -e  "truncate $T"
		UPLOAD="$UPLOAD "$T
		;;
	   *)
		$CQLSH -e  "truncate $T; COPY authz.${T} FROM '${T}.dat' WITH DELIMITER='|'"
		;;
	esac
    fi
done

# if [ ! "$UPLOAD" = "" ]; then
#     java -DCASS_ENV=$ENV -cp etc:authz-batch-2.0.18-jar-with-dependencies.jar com.att.authz.Batch Upload $UPLOAD
# fi
echo `date`
