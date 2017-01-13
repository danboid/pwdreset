#!/bin/bash
#
# Linux Active Directory desktop password reset script by Dan MacDonald 2016
# 
# Script to easily reset the passwords of your AD, cntlm proxy and local Linux users.
#
# This script needs to be run as root and you must have samba installed complete
# with at least a default /etc/smb.conf in place for AD domain password reset to work eg:
#
# cp /etc/samba/smb.conf.default /etc/samba/smb.conf
#
# Make sure all the following variables are set correctly and the samba daemon (smbd) is 
# running before you execute this script:

ADUSER=Your_Active_Directory_username
ADDC=Your_AD_Domain_Controller_address
UNIXUSER=Your_regular_Linux_username
OLDPASS=Your_current_AD_password
NEWPASS=New_password_for_all_things

# You shouldn't need to change anything past this point

HASHPASS=$(echo $NEWPASS | cntlm -H | grep PassNTLMv2)

echo -e "Resetting regular AD user password:\n"
(echo $OLDPASS; echo $NEWPASS; echo $NEWPASS) | smbpasswd -s -U $ADUSER -r $ADDC

echo -e "Resetting matching AD dollar user account password:\n"
(echo $OLDPASS; echo $NEWPASS; echo $NEWPASS) | smbpasswd -s -U \$$ADUSER -r $ADDC

echo -e "Updating cntlm proxy password hash:\n"
sed -i "s/^PassNTLMv2.*/$HASHPASS/" /etc/cntlm.conf

echo -e "Restarting cntlm proxy:\n"
systemctl restart cntlm

echo -e "Changing local regular user password:\n"
echo -e "$UNIXUSER:$NEWPASS" | chpasswd

echo -e "Changing local root user password:\n"
echo -e "root:$NEWPASS" | chpasswd
