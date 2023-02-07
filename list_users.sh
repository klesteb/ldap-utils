#!/bin/sh
#
# Date: 2022-11-14
# By  : Kevin Esteb
#
# This script will list users in ldap.
#
# Defaults
#
. $HOME/ldap/common.sh
#
usage() {
cat << EOF

usage $0 [options]
 
This script lists the groups from LDAP
 
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
echo "--------------------"
echo "Showing  ${LDAP_USER_DN}"
echo "--------------------"
ldapsearch -x -w "$LDAP_PASSWD" -b "${LDAP_USER_DN}" -D "${LDAP_ADMIN_DN}"
