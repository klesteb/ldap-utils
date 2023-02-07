#!/bin/bash
#
# Date: 2022-12-07
# By  : Kevin Esteb
#
# Add a user to ldap
#
. $HOME/ldap/common.sh
. /etc/adduser.conf
#
SN=
CN=
GECOS=
IS_ADMIN=0
USER_PASS=
USER_NAME=
CHANGE_DATE=
LDAP_OPTIONS=
HOME=${DHOME}
SHELL=${DSHELL}
SHADOW_MIN=0
SHADOW_FLAG=0
SHADOW_MAX=99999
SHADOW_WARNING=7
SHADOW_EXPIRE=-1
SHADOW_LAST_CHANGE=$(echo "$(date +%s) / ( 60 * 60 * 24 )" | bc)
#
usage() {
cat << EOF

usage $0 [options] <name>
 
This script creates a user in LDAP
 
OPTIONS
  -h    Show this message
  -i    Users uid
  -g    Users gid
  -h    Users home directory
  -s    Users shell to use
  -x    Users gecos (must be quoted)
  -w    Add to wheel group
  -f    Force password change on initial login
  -t    Test. Show what would be done, but don’t actually modify LDAP.
  
EOF
}
#
# parse command line
#
while getopts "htwfi:g:d:s:x:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 0
      ;;
    d)
      HOME=$OPTARG
      ;;
    g)
      GROUP_ID=$OPTARG
      ;;
    i)
      USER_ID=$OPTARG
      ;;
    s)
      SHELL=$OPTARG
      ;;
    x)
      GECOS=$OPTARG
      ;;
    w)
      IS_ADMIN=1
      ;;
    f)
      SHADOW_LAST_CHANGE=0
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
# fix up variables
#
if [ -z $GROUP_ID ]; then
    next_gid
fi
if [ -z $USER_ID ]; then
    next_uid
fi
if [ -z "$GECOS" ]; then
  GECOS="$USER_NAME"
fi
#
SN="`echo "$GECOS" | awk '{print $2}'`"
CN="`echo "$GECOS" | awk '{print $1}'`"
if [ -z "$SN" ]; then
  SN="$USER_NAME"
fi
#
read -ers -p "Password: " USER_CLEARTEXT_PASS
echo
USER_PASS=`slappasswd -h {SSHA} -s $USER_CLEARTEXT_PASS`
unset USER_CLEARTEXT_PASS
#
# create the ldif
#
LDIF=$(cat << EOF
dn: uid=${USER_NAME},${LDAP_USER_DN}
objectClass: top
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: ${USER_NAME}
cn: ${CN}
sn: ${SN}
givenName: ${CN}
displayName: ${GECOS}
userPassword: ${USER_PASS}
gecos: ${GECOS}
loginShell: ${SHELL}
uidNumber: ${USER_ID}
gidNumber: ${GROUP_ID}
homeDirectory: ${HOME}/${USER_NAME}
shadowMin: ${SHADOW_MIN}
shadowMax: ${SHADOW_MAX}
shadowFlag: ${SHADOW_FLAG}
shadowExpire: ${SHADOW_EXPIRE}
shadowWarning: ${SHADOW_WARNING}
shadowLastChange: ${SHADOW_LAST_CHANGE}

dn: cn=${USER_NAME},${LDAP_GROUP_DN}
objectClass: top
objectClass: posixGroup
gidNumber: ${GROUP_ID}
EOF
)
#
echo $LDIF
echo "--------------------"
echo "Adding ${USER_NAME}"
echo "--------------------"
echo "$LDIF" | ldapadd -x -w "$LDAP_PASSWD" -D "${LDAP_ADMIN_DN}" $LDAP_OPTIONS
#
if [ $IS_ADMIN != 0 ]
then
#
LDIF=$(cat << EOF
dn: cn=${LDAP_ADMIN_GROUP},${LDAP_GROUP_DN}
changetype: modify
add: memberuid
memberuid: ${USER_NAME}
EOF
)
#
echo "---------------------------------------"
echo "Adding ${USER_NAME} to ${LDAP_ADMIN_GROUP}"
echo "---------------------------------------"
echo "$LDIF" | ldapmodify -x -w "${LDAP_PASSWD}" -D "${LDAP_ADMIN_DN}" $LDAP_OPTIONS
#
fi
#