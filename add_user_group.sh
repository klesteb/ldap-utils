#!/bin/sh
#
# Date: 2022-11-13
# By  : Kevin Esteb
#
# This script will add a user to a group in ldap.
#
# Defaults
#
. $HOME/ldap/common.sh
#
usage() {
cat << EOF

usage $0 [options] <user> <group>
 
This script add a user to a group in LDAP
 
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
GROUP_NAME=$2
#
#
LDIF=$(cat << EOF
dn: cn=${GROUP_NAME},${LDAP_GROUP_DN}
changetype: modify
add: memberuid
memberuid: ${USER_NAME}
EOF
)
#
echo "---------------------------------------"
echo "Adding ${USER_NAME} to ${GROUP_NAME}"
echo "---------------------------------------"
echo "$LDIF" | ldapmodify -x -w "${LDAP_PASSWD}" -D "${LDAP_ADMIN_DN}" $LDAP_OPTIONS
