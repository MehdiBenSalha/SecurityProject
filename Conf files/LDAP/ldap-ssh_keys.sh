#!/bin/bash
ldapsearch -x -LLL -H ldapi:/// -D "cn=admin,dc=insat,dc=tn" -W -b
 "ou=user,dc=insat,dc=tn" "(uid=$1)" sshPublicKey | grep -oP "sshPublicKey: \K.*"