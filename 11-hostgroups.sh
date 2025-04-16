#!/bin/bash -x
# Pre-req: 08-setup-activationkeys.sh Completed
# Pre-req: 09-capsule-certs.sh Completed
# Pre-req: expect rpm installed
# Pre-req: Local .pwd file contains desired password to be passed as default root. Replace with keystore as required.

# for org in MYMAINORG ORG2; do
for org in MYMAINORG; do
  for os in rhel9 rhel8; do
    hammer hostgroup create --organization $org --name hg_$os

    # Apply relevant hostgroup changes at this level:
    # Partition table:
    hammer hostgroup update --organization $org --title hg_rhel9 --partition-table 'Kickstart default'
    # Set default root:
    expect -c "spawn hammer hostgroup update --organization $org --title hg_rhel9 --ask-root-password true; expect "group:" ; send \"$(<.pwd)\r\"; expect eof"
    # Set the content view to that of this major OS:
    hammer hostgroup update --organization $org --title hg_$os --content-view cv_$os


    # Proceed to nested location tier:
    for loc in lab:o2lj-satt2-cap01.iplab.au.singtelgroup.net; do
      area=`echo $loc|cut -d: -f1`
      capsule=`echo $loc|cut -d: -f2`
      hammer hostgroup create --organization $org --name $area --parent-title hg_$os

      # Apply relevant hostgroup changes at this level
      hammer hostgroup update --organization $org --title hg_$os/$area --content-source $capsule

      # Proceed to nested environment tier:
      for env in stage nonprod prod; do
        hammer hostgroup create --organization $org --name $env --parent-title hg_$os/$area

        # Apply relevant hostgroup changes at this level
        hammer hostgroup update --organization $org --title hg_$os/$area/$env --lifecycle-environment lce_$env

        # Apply activation key
        hammer hostgroup set-parameter --hostgroup-title hg_$os/$area/$env --name kt_activation_keys --value ak_${os}_${env}
      done
    done
  done
done
