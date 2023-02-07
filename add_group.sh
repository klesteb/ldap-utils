#!/bin/sh
#
# Date: 2022-11-13
# By  : Kevin Esteb
#
# This script will create a group in ldap.
#
# Defaults
#
. $HOME/ldap/common.sh
#
GROUP_NAME=
# 
usage() {
cat << EOF

usage $0 [options] <name>
 
This script creates a group in LDAP
 
OPTIONS
  -h    Show this message
  -g    Group gid
  -t    Test. Show what would be done, but don’t actually modify LDAP.

EOF
}
#
while getopts "hg:t" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    g)
      GROUP_ID=$OPTARG
      ;;
    t)
      LDAP_OPTIONS=" -n "
      ;;
    ?)
      usage
      exit
      ;;
  esac
done
#
if [ "$OPTIND" -gt "$#" ]; then
  usage
  exit 2
fi
#
shiftcount=`expr $OPTIND - 1`
shift $shiftcount
GROUP_NAME=$1
#
# If GROUP_ID not supplied, find next one using ldap query
#
if [ -z $GROUP_ID ]
then
  next_gid
fi
#
LDIF=$(cat << EOF
dn: cn=${GROUP_NAME},${LDAP_GROUP_DN}
objectClass: top
objectClass: posixGroup
gidNumber: ${GROUP_ID}
EOF
)
#
echo "--------------------"
echo "Adding ${LDIF}"
echo "--------------------"
echo "$LDIF" | ldapadd -x -w "${LDAP_PASSWD}" -D "${LDAP_ADMIN_DN}" $LDAP_OPTIONS
