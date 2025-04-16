#!/bin/bash -x

# Pre-req: Completed 08-setup-activationkeys.sh
ORG=MYMAINORG
CAPSULE=mycapsule.example.com
ssh-copy-id $CAPSULE

# clean any former capsule system registration
ssh $CAPSULE subscription-manager unregister
ssh $CAPSULE subscription-manager clean

# remove former rpm that associates /etc/rhsm/rhsm.conf with satellite and populates satellite certs
ssh $CAPSULE dnf -y remove katello-ca-consumer*

# download and install the latest such rpm to point this system at satellite:
ssh $CAPSULE wget -c --no-check-certificate https://`hostname -f`/pub/katello-ca-consumer-latest.noarch.rpm
ssh $CAPSULE rpm -i /root/katello-ca-consumer-latest.noarch.rpm

# register this system as a client OS of satellite, using the ak_capsule activation key:
ssh $CAPSULE subscription-manager register --org $ORG --activationkey ak_capsule --force

# access to yum repo content on satellite should now work. Update the OS and deploy the capsule installer:
ssh $CAPSULE dnf -y update
ssh $CAPSULE dnf -y install satellite-capsule

# prepare the capsule certs. Capture the output of the command as it contains the installer command that needs to be run on the capsule
CAPSULE_CERTS=/root/$CAPSULE-certs.tar
capsule-certs-generate --foreman-proxy-fqdn $CAPSULE --certs-tar $CAPSULE-certs 2>&1|sed -n '/  satellite-installer/,$p' |sed "s@--certs-tar-file.*@--certs-tar-file \"$CAPSULE_CERTS\"@" | ssh $CAPSULE cat \> /root/capsule-installer.sh \; chmod +x /root/capsule-installer.sh

# Copy the certs over:
scp $CAPSULE_CERTS root@$CAPSULE:$CAPSULE_CERTS

# Run the capsule installer:
ssh $CAPSULE /root/capsule-installer.sh

# Tell Satellite which organizations its new Capsule will be in and what content to syncrhonize to it:
# hammer capsule update --name $CAPSULE --organization-titles ORG2,$ORG
hammer capsule update --name $CAPSULE --organization-title $ORG
for LCE in lce_stage lce_nonprod lce_prod; do
  hammer capsule content add-lifecycle-environment --name $CAPSULE --organization $ORG --lifecycle-environment $LCE
done
# Make Satellite talk to the capsule without using the proxy (updating any exceptions already listed)
NO_PROXY_LIST=`hammer settings info --id http_proxy_except_list|awk '/^Value:/{$1="";print $0}'|tr -d " "`
case "$NO_PROXY_LIST" in
  \[\])                 NO_PROXY_LIST="[\"$CAPSULE\"]";;
  *\"$CAPSULE\"*)       ;;
  *)                    NO_PROXY_LIST=`echo $NO_PROXY_LIST|sed 's@]@, "'$CAPSULE'"]@'`;;
esac
hammer settings set --name http_proxy_except_list --value "$NO_PROXY_LIST"

# Open port 443 on the on-capsule firewall:
ssh $CAPSULE firewall-cmd --zone=public --add-port=443/tcp --permanent \; firewall-cmd --reload

hammer capsule content synchronize --name $CAPSULE --organization $ORG --skip-metadata-check true

# Tell the user where the capsule is at:
echo "Capsule will be running at https://$CAPSULE:9090"
