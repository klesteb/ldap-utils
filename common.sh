#
# Date: 2022-11-14
# By  : Kevin Esteb
#
# default variables and functions for ldap utilities.
#
USER_ID=
GROUP_ID=
LDAP_OPTIONS=
LDAP_PASSWD=changeme
LDAP_ADMIN_GROUP=changeme
LDAP_BASE=dc=changeme,dc=changeme
LDAP_ADMIN_DN=cn=admin,${LDAP_BASE}
LDAP_USER_DN=ou=people,${LDAP_BASE}
LDAP_GROUP_DN=ou=groups,${LDAP_BASE}
#
# common functions
#
error_ldap() {
  echo "Error: Error connecting to LDAP or uninitialized user tree"
}
#
next_gid() {
  HIGHEST_GID=`ldapsearch -x -w "${LDAP_PASSWD}" -b "${LDAP_GROUP_DN}" -D "${LDAP_ADMIN_DN}" '(objectclass=posixGroup)' gidNumber | grep -e '^gid' | cut -d':' -f2 | sort | tail -1`
  if [ -z $HIGHEST_GID ]
  then
    error_ldap
    exit 1
  fi
  GROUP_ID=`expr $HIGHEST_GID + 1`
}
#
next_uid() {
  HIGHEST_UID=`ldapsearch -x -w "$LDAP_PASSWD" -b "${LDAP_USER_DN}" -D "${LDAP_ADMIN_DN}" "(objectclass=posixaccount)" uidnumber | grep -e '^uid' | cut -d':' -f2 | sort | tail -1`
  if [ -z $HIGHEST_UID ]
  then
    error_ldap
    exit 1
  fi
  USER_ID=`expr $HIGHEST_UID + 1`
}
#
