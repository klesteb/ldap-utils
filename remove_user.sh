#!/bin/sh
#
# Date: 2022-11-14
# By  : Kevin Esteb
#
# This script will remove a user in ldap.
#
# Defaults
#
. $HOME/ldap/common.sh
#
USER_NAME=
#
usage() {
cat << EOF

usage $0 [options] <name>
 
This script removes a user from LDAP
 
OPTIONS
  -h    Show this message
  -t    Test. Show what would be done, but don’t actually modify LDAP.

EOF
}
#
while getopts "ht" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
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
USER_NAME=$1
#
USER=uid=${USER_NAME},${LDAP_USER_DN}
#
echo "--------------------"
echo "Removing  ${USER}"
echo "--------------------"
ldapdelete -x -w "$LDAP_PASSWD" -D "${LDAP_ADMIN_DN}" $LDAP_OPTIONS "${USER}"
